//
//  NSString+BBAURL.h
//  BBAFoundation
//
//  Created by Zhu,Yusong on 2018/9/26.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 字符串 URL 相关的扩展
 * 详细介绍请看README-BBAURL
 */

@interface NSString (BBAURL)

/**
 * @brief query字符串转字典, 会对querry进行反转义
 *
 * @return NSDictionary
 */
- (NSDictionary *)bdp_queryDictionary;

/**
 * @brief 字典转query字符串，会对字典的value值进行转义
 *
 * @param queryDictionary 字典
 * @return NSString query
 */
+ (NSString *)bdp_queryStringWithDictionary:(NSDictionary *)queryDictionary;

/**
 * @brief 字符串 URL 转义
 *
 * @return 转义后的字符串
 *
 * @note This will also escape '%', so this should not be used on a string that has already been escaped unless double-escaping is the desired result.
 * Encode all the reserved characters, per RFC 3986 (<http://www.ietf.org/rfc/rfc3986.txt>)
 * 对应js的encodeURIComponent
 */
- (NSString *)bdp_encodeURIComponent;

/**
 * @brief 字符串 URL 反转义
 *
 * @return Returns the unescaped version of a URL argument
 *
 * @note This has the same behavior as stringByReplacingPercentEscapesUsingEncoding:,
 * except that it will also convert '+' to space.
 * 对应js的decodeURIComponent
 */
- (NSString *)bdp_decodeURIComponent;


@end
