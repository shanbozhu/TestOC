//
//  NSString+BBAMD5.m
//  BBAPods
//
//  Created by 00 on 2016/12/29.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "NSString+BBAMD5.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (BBAMD5)

+ (NSString * __nullable)bdp_md5:(NSString *)aInput {
    if (aInput == nil || ![aInput isKindOfClass:[NSString class]] || [aInput length] == 0) {
        NSAssert(NO, @"入参NSString 为空或者 不是NSString类型");
        return nil;
    }
    
    const char *cStr = [aInput UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+ (NSString * __nullable)bdp_md5Data:(NSData *)aInputData {
    if ([aInputData isKindOfClass:[NSData class]] == NO || aInputData.length == 0) {
        NSAssert(NO, @"入参NSData 为空或者 不是NSData类型");
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([aInputData bytes], (CC_LONG)aInputData.length, digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+ (NSString * __nullable)bdp_fileMD5HashCreateWithPath:(NSString *)filePath {
    if (!filePath || ![filePath isKindOfClass:[NSString class]] || 0 == [filePath length]) {
        NSAssert(NO, @"入参NSString 为空或者 不是NSString类型");
        return nil;
    }
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[4096];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    
    return (__bridge NSString *)(result);
}

@end
