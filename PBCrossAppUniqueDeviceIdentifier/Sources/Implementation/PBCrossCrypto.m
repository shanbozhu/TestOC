//
//  PBCrossCrypto.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossCrypto.h"
#import <CommonCrypto/CommonCrypto.h>

static NSString *PBCrossHexString(const unsigned char *bytes, NSUInteger length)
{
    static const char hexDigits[] = "0123456789abcdef";
    if (bytes == NULL || length == 0) {
        return @"";
    }

    char *buffer = malloc(length * 2 + 1);
    if (buffer == NULL) {
        return @"";
    }
    for (NSUInteger index = 0; index < length; index++) {
        buffer[index * 2] = hexDigits[(bytes[index] >> 4) & 0x0F];
        buffer[index * 2 + 1] = hexDigits[bytes[index] & 0x0F];
    }
    buffer[length * 2] = '\0';

    NSString *result = [NSString stringWithUTF8String:buffer];
    free(buffer);
    return result ?: @"";
}

@implementation PBCrossCrypto

+ (NSString *)MD5HexString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, digest);
#pragma clang diagnostic pop
    return PBCrossHexString(digest, CC_MD5_DIGEST_LENGTH);
}

+ (NSString *)SHA256HexString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    return PBCrossHexString(digest, CC_SHA256_DIGEST_LENGTH);
}

+ (NSString *)HMACSHA256HexString:(NSString *)string key:(NSString *)key
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding] ?: [NSData data];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, keyData.bytes, keyData.length, data.bytes, data.length, digest);
    return PBCrossHexString(digest, CC_SHA256_DIGEST_LENGTH);
}

+ (NSString *)randomUUIDString
{
    return [[[NSUUID UUID] UUIDString] lowercaseString];
}

@end
