//
//  NSData+BBAEncode.h
//  BBAFoundation
//
//  Created by Zhu,Yusong on 2018/9/24.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 * Data 加密相关扩展
 * 详细介绍请看README-Encode
 */

@interface NSData (BBAEncode)

/**
 * @brief Calculate the md5 hash of this data using CC_MD5.
 *
 * @return md5 hash of this data
 */
@property (nonatomic, readonly) NSString* bdp_md5Hash;

/**
 * @brief Calculate the SHA1 hash of this data using CC_SHA1.
 *
 * @return SHA1 hash of this data
 */
@property (nonatomic, readonly) NSString* bdp_sha1Hash;

/**
 * @brief Create an NSData from a base64 encoded representation
 *
 * @return the NSData object
 *
 * @note Padding '=' characters are optional. Whitespace is ignored.
 */
+ (NSData *)bdp_dataWithBase64EncodedString:(NSString *)string;

/**
 * @brief Marshal the data into a base64 encoded representation
 *
 * @return the base64 encoded string
 */
- (NSString *)bdp_base64Encoding;

@end

NS_ASSUME_NONNULL_END
