//
//  NSData+BBAEncode.m
//  BBAFoundation
//
//  Created by Zhu,Yusong on 2018/9/24.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "NSData+BBAEncode.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (BBAEncode)

- (NSString*)bdp_md5Hash {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], (uint32_t)[self length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)bdp_sha1Hash {
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([self bytes], (uint32_t)[self length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
            result[16], result[17], result[18], result[19]
            ];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// base64 code found on http://www.cocoadev.com/index.pl?BaseSixtyFour
// where the poster released it to public domain
// style not exactly congruous with normal three20 style, but kept mostly intact with the original
static const char encodingTable[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSData*)bdp_dataWithBase64EncodedString:(NSString *)string {
    if (nil == string || ![string isKindOfClass:[NSString class]] || 0 == [string length]) {
        NSAssert(NO, @"入参NSString 为空或者 不是NSString类型");
        return [NSData data];
    }
    // 初始化 decodingTable
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    if (bytes == NULL) {
        return nil;
    }
    return [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)bdp_base64Encoding {
    if ([self length] == 0)
        return @"";
    
    char *characters = malloc((([self length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [self length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [self length])
            buffer[bufferLength++] = ((char *)[self bytes])[i++];
        
        // Encode the bytes in the buffer to four characters,
        // including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length
                                        encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

#pragma mark - Deprecated Methods

- (NSString*)bba_md5Hash {
    return [self bdp_md5Hash];
}

- (NSString*)bba_sha1Hash {
    return [self bdp_sha1Hash];
}

+ (NSData*)bba_dataWithBase64EncodedString:(NSString *)string {
    return [self bdp_dataWithBase64EncodedString:string];
}

- (NSString *)bba_base64Encoding {
    return [self bdp_base64Encoding];
}

@end
