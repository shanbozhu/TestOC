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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 链接_自动匹配
    {
        NSString *str = @"我爱www.lala.com北京天安   门www.hah a.com";
        NSArray *result = [[PBRegex regexUrl] matchesInString:str options:kNilOptions range:NSMakeRange(0, str.length)];
        for (NSTextCheckingResult *at in result) {
            if (at.range.location == NSNotFound && at.range.length <= 1) {
                continue;
            }
            //NSLog(@"at = %@", at);
            NSLog(@"[str substringWithRange:at.range] = %@", [str substringWithRange:at.range]);
        }
    }
}

@end
