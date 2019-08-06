//
//  AppDelegate+UniversalLink.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/8/6.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "AppDelegate+UniversalLink.h"

@implementation AppDelegate (UniversalLink)

// URLScheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"url.absoluteString = %@", url.absoluteString);
    
    if ([url.scheme isEqualToString:@"TestBundleAAA"]) {
        // xxx
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Link" object:nil userInfo:@{@"url":url}];
    }
    return YES;
}

// UniversalLink
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        NSLog(@"url.absoluteString = %@", url.absoluteString);
        
        if ([url.host isEqualToString:@"damai.cn"]) {
            // xxx
            [[NSNotificationCenter defaultCenter]postNotificationName:@"Link" object:nil userInfo:@{@"url":url}];
        } else {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication]openURL:url];
            }
        }
    }
    return YES;
}

@end
