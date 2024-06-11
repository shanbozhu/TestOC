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
    // OC 正则表达式的语法及使用 https://www.jianshu.com/p/3fc785cad3d7
    
    // 链接_自动匹配
    {
        NSString *str = @"我爱www.lala.com北\n\n\n京天安   门http://www.hah1a.com";
        NSArray *result = [[PBRegex regexUrl] matchesInString:str options:kNilOptions range:NSMakeRange(0, str.length)];
        for (NSTextCheckingResult *at in result) {
            //NSLog(@"at = %@", at);
            NSLog(@"[str substringWithRange:at.range] = %@", [str substringWithRange:at.range]);
        }
    }
    
    // ^：匹配开始位置，^(a)匹配开头必须为a
    [self regexMatch:@"abxuuu2uu我" pattern:@"^(a)"];
    
    // $：匹配结束位置，$(a)匹配结尾必须为a
    [self regexMatch:@"bxuuu2uu我a" pattern:@"$(a)"];
    
    // *：匹配前面的子表达式零次或多次。如"xu*"这个表达式就能够匹配"x"和"xuu"，子表达式是"u"
    [self regexMatch:@"xuuu2uu我" pattern:@"xu*"];
    
    // +：匹配前面的子表达式一次或多次。如“xu+”这个表达式就能够匹配"xuu"和"xu"，但不能够匹配"x"，这就是和"*"的区别
    [self regexMatch:@"xuuu2uu我" pattern:@"xu+"];
    
    // ?：匹配前面的子表达式零次或一次。如"jian(guo)?"这个表达式就能够匹配"jian"和"jianguo"
    [self regexMatch:@"jian我" pattern:@"jian(guo)?"];
    
    // {n}：n是一个非负数，匹配n次。如"guo{2}"，可以匹配"guoo"，不能匹配"guo"
    [self regexMatch:@"guoooooooo我" pattern:@"guo{2}"];
    
    // {n,}：n是一个非负数，匹配至少n次。如"guo{2,}"，可以匹配"guooooooo"
    [self regexMatch:@"guooooooo我" pattern:@"guo{2,}"];
    
    // {n,m}：m、n都是非负数，最少匹配n次，最多匹配m次
    [self regexMatch:@"guooooooo我" pattern:@"guo{2, 5}"];
    
    // (pattern)：匹配pattern并获取匹配结果
    [self regexMatch:@"guooooooo我" pattern:@"(uoo)"];
    
    // (?:pattern)：匹配pattern但不获取匹配结果
    [self regexMatch:@"guooooooo我" pattern:@"(?:uooo)"];
    
    // [xyz]：字符集合，匹配所包含的任意字符。如"[abc]"可以匹配"apple"中的"a"
    [self regexMatch:@"apple我" pattern:@"[abc]"];
    
    // [^xyz]：匹配未被包含的字符
    [self regexMatch:@"apple我" pattern:@"[^abc]"];
    
    // [a-z]：字符范围，匹配指定范围内的任意字符
    [self regexMatch:@"apple123我" pattern:@"[a-z]"];
    
    // [^a-z]：匹配不在指定范围内的任意字符
    [self regexMatch:@"apple123我" pattern:@"[^a-z]"];
    
    // \b：匹配一个单词的边界，如"guo\b"可以匹配"xujianguo"中的"guo"
    [self regexMatch:@"xujian 我guo" pattern:@"guo\\b"];
    
    // \B：匹配非单词边界，如"jian\B"可以匹配"xujianguo"中的"jian"
    [self regexMatch:@"xujianguo我" pattern:@"jian\\B"];
    
    // \d：匹配一个数字字符，等价于"[0-9]"
    [self regexMatch:@"apple123我" pattern:@"\\d"];
    
    // \D：匹配一个非数字字符
    [self regexMatch:@"apple123我" pattern:@"\\D"];
    
    // \f：匹配一个换页符
    // \t：匹配一个制表符
    
    // \n：匹配一个换行符
    [self regexMatch:@"apple\n123我" pattern:@"\\n"];
    
    // \r：匹配一个回车符
    [self regexMatch:@"apple\r123我" pattern:@"\\r"];
    
    // \s：匹配任何空白字符
    [self regexMatch:@"apple\r \n123我" pattern:@"\\s"];
    
    // x|y：匹配x或y
    [self regexMatch:@"xuguojianguo123我" pattern:@"(xu|jian)guo"];
    
    // .：匹配除换行符以外的任意字符
    [self regexMatch:@"apple\r  \n\t123我" pattern:@"."];
    
    // \w：匹配标识符(数字、下划线、英文字母)和汉字，等价于"[a-zA-Z0-9\u4E00-\u9FFF_]"
    [self regexMatch:@"xuguojianguo_123-=/我" pattern:@"\\w"];
    
    // \W：匹配非\w的字符
    // \S：匹配非\s的字符
    // \D：匹配非\d的字符
    // \B：匹配非\b的字符
    
    
    
    // \num：num为一个整数，匹配前面的表达式复制num次
    [self regexMatch:@"appleabababa123" pattern:@"(ab)\3"];
    
}

@end
