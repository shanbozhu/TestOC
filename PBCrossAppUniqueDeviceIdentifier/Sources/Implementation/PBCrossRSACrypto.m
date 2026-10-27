//
//  PBCrossRSACrypto.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossRSACrypto.h"
#import "PBCrossConfiguration.h"
#import "PBCrossErrors.h"
#include <TargetConditionals.h>
#include <stdlib.h>

static NSData *PBCrossBase64DataFromString(NSString *string)
{
    if (string.length == 0) {
        return nil;
    }

    NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmed rangeOfString:@"-----BEGIN"].location != NSNotFound) {
        NSMutableString *base64 = [NSMutableString string];
        NSArray<NSString *> *lines = [trimmed componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for (NSString *line in lines) {
            NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (trimmedLine.length == 0 || [trimmedLine hasPrefix:@"-----"]) {
                continue;
            }
            [base64 appendString:trimmedLine];
        }
        trimmed = base64;
    }

    return [[NSData alloc] initWithBase64EncodedString:trimmed
                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

static BOOL PBCrossDERReadElement(const uint8_t *bytes,
                                  NSUInteger length,
                                  NSUInteger *offset,
                                  uint8_t *tag,
                                  NSUInteger *contentOffset,
                                  NSUInteger *contentLength)
{
    NSUInteger position = *offset;
    if (position + 2 > length) {
        return NO;
    }

    uint8_t tagByte = bytes[position++];
    uint8_t lengthByte = bytes[position++];
    NSUInteger elementLength = 0;

    if ((lengthByte & 0x80) != 0) {
        NSUInteger byteCount = lengthByte & 0x7F;
        if (byteCount == 0 || byteCount > sizeof(NSUInteger) || position + byteCount > length) {
            return NO;
        }
        for (NSUInteger index = 0; index < byteCount; index++) {
            elementLength = (elementLength << 8) | bytes[position++];
        }
    } else {
        elementLength = lengthByte;
    }

    if (elementLength > length - position) {
        return NO;
    }

    *tag = tagByte;
    *contentOffset = position;
    *contentLength = elementLength;
    *offset = position + elementLength;
    return YES;
}

/// 从 SubjectPublicKeyInfo 中取出 PKCS#1 RSAPublicKey。
static NSData *PBCrossPKCS1PublicKeyFromSPKI(NSData *data)
{
    if (data.length < 2) {
        return nil;
    }

    const uint8_t *bytes = data.bytes;
    NSUInteger length = data.length;
    NSUInteger offset = 0;
    uint8_t tag = 0;
    NSUInteger contentOffset = 0;
    NSUInteger contentLength = 0;

    if (!PBCrossDERReadElement(bytes, length, &offset, &tag, &contentOffset, &contentLength)) {
        return nil;
    }
    if (tag != 0x30) {
        return nil;
    }

    NSUInteger sequenceEnd = contentOffset + contentLength;
    offset = contentOffset;

    // AlgorithmIdentifier
    if (!PBCrossDERReadElement(bytes, sequenceEnd, &offset, &tag, &contentOffset, &contentLength)) {
        return nil;
    }
    if (tag != 0x30) {
        return nil;
    }

    // BIT STRING
    if (!PBCrossDERReadElement(bytes, sequenceEnd, &offset, &tag, &contentOffset, &contentLength)) {
        return nil;
    }
    if (tag != 0x03 || contentLength < 2 || bytes[contentOffset] != 0x00) {
        return nil;
    }

    NSUInteger keyOffset = contentOffset + 1;
    NSUInteger keyLength = contentLength - 1;
    if (keyOffset + keyLength > length) {
        return nil;
    }
    return [NSData dataWithBytes:(bytes + keyOffset) length:keyLength];
}

static SecKeyRef PBCrossCreateRSAKeyFromDER(NSData *data)
{
    if (data.length == 0) {
        return NULL;
    }

    NSDictionary *attributes = @{
        (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPublic,
    };
    CFErrorRef error = NULL;
    SecKeyRef key = SecKeyCreateWithData((__bridge CFDataRef)data,
                                         (__bridge CFDictionaryRef)attributes,
                                         &error);
    if (error) {
        CFRelease(error);
    }
    return key;
}

/// 去除 PKCS#1 Type 1 padding：00 01 FF...FF 00 || message（某些实现会丢掉开头的 00）。
static NSData *PBCrossPKCS1Type1UnpaddedData(NSData *paddedData)
{
    const uint8_t *bytes = paddedData.bytes;
    NSUInteger length = paddedData.length;
    if (length < 3) {
        return nil;
    }

    NSUInteger index = 0;
    if (bytes[index] == 0x00) {
        index++;
    }
    if (index >= length || bytes[index] != 0x01) {
        return nil;
    }
    index++;

    while (index < length && bytes[index] == 0xFF) {
        index++;
    }
    if (index >= length || bytes[index] != 0x00) {
        return nil;
    }
    index++;

    return [paddedData subdataWithRange:NSMakeRange(index, length - index)];
}

@implementation PBCrossRSACrypto

+ (nullable SecKeyRef)PBCopyPublicKeyFromString:(NSString *)publicKeyString
                                          error:(NSError **)error
{
    NSData *data = PBCrossBase64DataFromString(publicKeyString);
    if (data.length == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorInvalidPublicKey, @"公钥 Base64 解码失败");
        }
        return NULL;
    }

    SecCertificateRef certificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    if (certificate != NULL) {
        SecKeyRef key = SecCertificateCopyKey(certificate);
        CFRelease(certificate);
        if (key != NULL) {
            return key;
        }
    }

    SecKeyRef key = PBCrossCreateRSAKeyFromDER(data);
    if (key != NULL) {
        return key;
    }

    NSData *pkcs1Data = PBCrossPKCS1PublicKeyFromSPKI(data);
    if (pkcs1Data.length > 0) {
        key = PBCrossCreateRSAKeyFromDER(pkcs1Data);
        if (key != NULL) {
            return key;
        }
    }

    if (error) {
        *error = PBCrossErrorMake(PBCrossRemoteErrorInvalidPublicKey,
                                  @"无法解析公钥，请检查证书/PEM 格式");
    }
    return NULL;
}

+ (nullable NSData *)encryptData:(NSData *)data
                       publicKey:(SecKeyRef)publicKey
                           error:(NSError **)error
{
    if (publicKey == NULL || data.length == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorEncryptionFailed, @"待加密数据或公钥为空");
        }
        return nil;
    }

    size_t blockSize = SecKeyGetBlockSize(publicKey);
    if (blockSize <= 11) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorEncryptionFailed, @"RSA 密钥长度异常");
        }
        return nil;
    }

    size_t maximumChunkSize = blockSize - 11;
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:data.length];
    NSUInteger offset = 0;

    while (offset < data.length) {
        NSUInteger chunkLength = MIN(maximumChunkSize, data.length - offset);
        NSData *chunk = [data subdataWithRange:NSMakeRange(offset, chunkLength)];

        CFErrorRef cfError = NULL;
        CFDataRef encryptedChunk = SecKeyCreateEncryptedData(publicKey,
                                                              kSecKeyAlgorithmRSAEncryptionPKCS1,
                                                              (__bridge CFDataRef)chunk,
                                                              &cfError);
        if (encryptedChunk == NULL) {
            if (cfError) {
                CFRelease(cfError);
            }
            if (error) {
                *error = PBCrossErrorMake(PBCrossRemoteErrorEncryptionFailed, @"RSA 分段加密失败");
            }
            return nil;
        }

        [encryptedData appendData:CFBridgingRelease(encryptedChunk)];
        offset += chunkLength;
    }

    return [encryptedData copy];
}

+ (nullable NSData *)decryptData:(NSData *)data
                       publicKey:(SecKeyRef)publicKey
                           error:(NSError **)error
{
    if (publicKey == NULL || data.length == 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorDecryptionFailed, @"待解密数据或公钥为空");
        }
        return nil;
    }

    size_t blockSize = SecKeyGetBlockSize(publicKey);
    if (blockSize == 0 || data.length % blockSize != 0) {
        if (error) {
            *error = PBCrossErrorMake(PBCrossRemoteErrorDecryptionFailed, @"密文长度与密钥不匹配");
        }
        return nil;
    }

    NSMutableData *decryptedData = [NSMutableData dataWithCapacity:data.length];
    NSUInteger offset = 0;

    while (offset < data.length) {
        NSData *block = [data subdataWithRange:NSMakeRange(offset, blockSize)];
        NSData *paddedBlock = nil;

        CFErrorRef cfError = NULL;
        CFDataRef decryptedBlock = SecKeyCreateDecryptedData(publicKey,
                                                              kSecKeyAlgorithmRSAEncryptionRaw,
                                                              (__bridge CFDataRef)block,
                                                              &cfError);
        if (decryptedBlock != NULL) {
            paddedBlock = CFBridgingRelease(decryptedBlock);
        } else {
            if (cfError) {
                CFRelease(cfError);
            }

#if TARGET_OS_IPHONE
            // SecKeyCreateDecryptedData 在部分系统上不允许用公钥做 Raw 解密，
            // 回退到与 CAID 文档一致的 SecKeyDecrypt(kSecPaddingNone)。
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            unsigned char *buffer = malloc(blockSize + 128);
            if (buffer == NULL) {
                if (error) {
                    *error = PBCrossErrorMake(PBCrossRemoteErrorDecryptionFailed, @"内存分配失败");
                }
                return nil;
            }
            size_t bufferLength = blockSize + 128;
            OSStatus status = SecKeyDecrypt(publicKey,
                                            kSecPaddingNone,
                                            block.bytes,
                                            block.length,
                                            buffer,
                                            &bufferLength);
#pragma clang diagnostic pop
            if (status == noErr) {
                paddedBlock = [NSData dataWithBytes:buffer length:bufferLength];
            }
            free(buffer);
#endif

            if (paddedBlock == nil) {
                if (error) {
                    *error = PBCrossErrorMake(PBCrossRemoteErrorDecryptionFailed, @"RSA 分段解密失败");
                }
                return nil;
            }
        }

        NSData *plainBlock = PBCrossPKCS1Type1UnpaddedData(paddedBlock);
        if (plainBlock == nil) {
            if (error) {
                *error = PBCrossErrorMake(PBCrossRemoteErrorDecryptionFailed, @"PKCS#1 padding 校验失败");
            }
            return nil;
        }

        [decryptedData appendData:plainBlock];
        offset += blockSize;
    }

    return [decryptedData copy];
}

@end
