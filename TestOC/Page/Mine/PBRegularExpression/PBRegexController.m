//
//  PBRegexController.m
//  TestOC
//
//  Created by shanbo on 2024/6/6.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRegexController.h"
#import "PBRegex.h"

@interface PBRegexController ()

@end

@implementation PBRegexController

- (void)regexMatch:(NSString *)str pattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:nil];
    NSArray *result = [regex matchesInString:str options:kNilOptions range:NSMakeRange(0, str.length)];
    for (NSTextCheckingResult *at in result) {
        NSLog(@"[str substringWithRange:at.range] = %@", [str substringWithRange:at.range]);
    }
    if (result.count <= 0) {
        NSLog(@"给定字符串中未匹配到指定子串样式!");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // OC 正则表达式详解 https://www.jianshu.com/p/efdf1cd950ab
    
    // 链接_自动匹配
    {
        NSString *str = @"我爱www.lala.com北\n\n\n京天安   门http://www.hah1a.com";
        NSArray *result = [[PBRegex regexUrl] matchesInString:str options:kNilOptions range:NSMakeRange(0, str.length)];
        for (NSTextCheckingResult *at in result) {
            //NSLog(@"at = %@", at);
            NSLog(@"[str substringWithRange:at.range] = %@", [str substringWithRange:at.range]);
        }
    }
    
    // 匹配开始位置，^(a)匹配开头必须为a
    [self regexMatch:@"abxuuu2uu" pattern:@"^(a)"];
    
    // 匹配结束位置，$(a)匹配结尾必须为a
    [self regexMatch:@"bxuuu2uua" pattern:@"$(a)"];
    
    // 匹配前面的子表达式零次或多次。如"xu*"这个表达式就能够匹配"x"和"xuu"，子表达式是"u"
    [self regexMatch:@"xuuu2uu" pattern:@"xu*"];
    
    // 匹配前面的子表达式一次或多次。如“xu+”这个表达式就能够匹配"xuu"和"xu"，但不能够匹配"x"，这就是和"*"的区别
    [self regexMatch:@"xuuu2uu" pattern:@"xu+"];
    
    // 匹配前面的子表达式零次或一次。如"jian(guo)?"这个表达式就能够匹配"jian"和"jianguo"
    [self regexMatch:@"jian" pattern:@"jian(guo)?"];
    
    // n是一个非负数，匹配n次。如"guo{2}"，可以匹配"guoo"，不能匹配"guo"
    [self regexMatch:@"guoooooooo" pattern:@"guo{2}"];
    
    // n是一个非负数，匹配至少n次。如"guo{2,}"，可以匹配"guooooooo"
    [self regexMatch:@"guooooooo" pattern:@"guo{2,}"];
    
    // m、n都是非负数，最少匹配n次，最多匹配m次
    [self regexMatch:@"guooooooo" pattern:@"guo{2,5}"];
    
    // 匹配pattern并获取匹配结果
    [self regexMatch:@"guooooooo" pattern:@"(uoo)"];
    [self regexMatch:@"guooooooo" pattern:@"uoo"];
}

@end
