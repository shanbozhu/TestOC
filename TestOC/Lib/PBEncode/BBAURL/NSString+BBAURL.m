//
//  NSString+BBAURL.m
//  BBAFoundation
//
//  Created by Zhu,Yusong on 2018/9/26.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "NSString+BBAURL.h"

@implementation NSString (BBAURL)

- (NSDictionary *)bdp_queryDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *keyAndValue = [pair componentsSeparatedByString:@"="];
        if ([keyAndValue count] == 2) {
            [result setObject:[keyAndValue objectAtIndex:1] forKey:[keyAndValue objectAtIndex:0]];
        } else if ([keyAndValue count] == 1) {
           [result setObject:@"" forKey:[keyAndValue objectAtIndex:0]];
        }
    }
    return [NSDictionary dictionaryWithDictionary:result];
}

+ (NSString *)bdp_queryStringWithDictionary:(NSDictionary *)queryDictionary {
    NSMutableArray *pairs = [NSMutableArray array];
    for ( NSString *key in [queryDictionary keyEnumerator] ) {
        id value = [queryDictionary objectForKey:key];
        if (![value isKindOfClass:[NSString class]]) continue;
        NSString * urlEncoding = [(NSString *)value bdp_encodeURIComponent];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, urlEncoding]];
    }
    return [pairs componentsJoinedByString:@"&"];
}

// Encode all the reserved characters, per RFC 3986 (<http://www.ietf.org/rfc/rfc3986.txt>)
// 对应js的encodeURIComponent
- (NSString *)bdp_encodeURIComponent {
    NSString *charactersToEscape = @":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`\n";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *newString = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return newString == nil ? @"" : newString;
}

// 对应js的decodeURIComponent
- (NSString *)bdp_decodeURIComponent {
    NSMutableString *resultString = [NSMutableString stringWithString:self];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return resultString.stringByRemovingPercentEncoding;
}

#pragma mark -

- (NSString *)bdp_percentEncoding {
    // 与oc提供的[NSCharacterSet URLQueryAllowedCharacterSet]方法相比，当前的字符串多了%字符
    // 不转义的字符集
    NSCharacterSet *escapedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%"];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:escapedCharacters];
}

@end
