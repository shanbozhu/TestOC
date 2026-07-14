//
//  AppDelegate+Menta.m
//  TestOC
//
//  Created by zhushanbo on 2026/7/14.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "AppDelegate+Menta.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>

@implementation AppDelegate (Menta)

- (void)setUpMentaSDK {
    [MUAPI enableLog:YES];
    /*
     canUseIDFA = NO 需要外部传入 IDFA
     [MUAPI canUseIDFA:NO];
     [MUAPI setCustomIDFA:@"TEST MU IDFA"];
    */
    [MUAPI canUseIDFA:YES];
    [MUAPI canUseLocation:YES];
    // 广协 ID
    // [MUAPI setPolluxValues:@[@"20230330_75c7bc3754b3019c135b526cb8eb4420", @"20220111_8799abe1c76805fab06ee3f98a3f704e"]];
    [MUAPI canUseCarrier:YES];
    [MUAPI setUserInfoWith:@"123" age:13 gender:MVUserGenderMale consumeLevel:MVUserConsumeLevelHigh];
    [MUAPI enableWriteToFile:YES];

    [MUAPI startWithAppID:@"A0624" appKey:@"7bbccdb9e6dcbe7e7176d2bf586331dc" finishBlock:^(BOOL success, NSError * _Nullable error) {}];
}

@end
