//
//  NSString+BBAMD5.h
//  BBAPods
//
//  Created by 00 on 2016/12/29.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * MD5加密（字符串、二进制和文件）
 * 详细介绍请看README
 */

@interface NSString (BBAMD5)

/**
 * @brief MD5加密-字符串
 *
 * @param aInput 字符串输入
 * @return 密文
 */
+ (NSString * __nullable)bdp_md5:(NSString *)aInput;

/**
 * @brief MD5加密-二进制
 *
 * @param aInputData 二进制输入
 * @return 密文
 */
+ (NSString * __nullable)bdp_md5Data:(NSData *)aInputData;

/**
 * @brief MD5加密-文件
 *
 * @param filePath 文件路径
 * @return 密文
 */
+ (NSString * __nullable)bdp_fileMD5HashCreateWithPath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
