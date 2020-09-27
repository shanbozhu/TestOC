//
//  PBRegex.m
//  TestOC
//
//  Created by DaMaiIOS on 17/9/23.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBRegex.h"

@implementation PBRegex

// 匹配@用户
+ (NSRegularExpression *)regexAt {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5]+" options:kNilOptions error:nil];
    });
    return regex;
}

// 匹配#话题
+ (NSRegularExpression *)regexTopic {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"#[^@#]+?#" options:kNilOptions error:nil];
    });
    return regex;
}

// 匹配邮件
+ (NSRegularExpression *)regexEmail {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" options:kNilOptions error:nil];
    });
    return regex;
}

// 匹配链接
+ (NSRegularExpression *)regexUrl {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" options:kNilOptions error:nil];
    });
    return regex;
}

// 匹配手机号
+ (NSRegularExpression *)regexPhone {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"1[34578]\\d{9}" options:kNilOptions error:nil];
    });
    return regex;
}

+ (NSRegularExpression *)regexString:(NSString *)string {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:string options:kNilOptions error:nil];
    });
    return regex;
}

@end
