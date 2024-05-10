//
//  NSString+BBAEnode.h
//  BBAFoundation
//
//  Created by Zhu,Yusong on 2018/9/20.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * 字符串 加密相关扩展
 * 详细介绍请看README-Encode
 */

@interface NSString (BBAEncode)

/**
 * @brief Calculate the md5 hash of this string using CC_MD5.
 *
 * @return md5 hash of this string
 */
@property (nonatomic, readonly) NSString *bdp_md5Hash;

/**
 * @brief Calculate the SHA1 hash of this string using CommonCrypto CC_SHA1.
 *
 * @return NSString with SHA1 hash of this string
 */
@property (nonatomic, readonly) NSString *bdp_sha1Hash;

@end

NS_ASSUME_NONNULL_END
