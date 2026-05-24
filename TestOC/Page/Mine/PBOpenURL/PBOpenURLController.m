//
//  PBOpenURLController.m
//  TestOC
//
//  Created by zhushanbo on 2026/5/23.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBOpenURLController.h"

@interface PBOpenURLController ()

@end

// 百度极速版活动页：
// https://activity.baidu.com/mbox/4a81aa9860/staticMiddlePage_3?appname=baiduboxlite
// https://activity.baidu.com/mbox/4a81a89b62/defaultNewsPage_1?appname=baiduboxlite&vid=3185394484734977936&channel=bd-sem&channel_id=1021077d&invoke_id=1020204t&query%3D

// 百度极速版 universal link 配置：
// https://wakeup.baidu.com/apple-app-site-association
// 百度主板 universal link 配置：
// https://boxer.baidu.com/apple-app-site-association
// https://boxer2.baidu.com/apple-app-site-association

// 百度极速版 universal link 地址：
// https://wakeup.baidu.com/baiduboxlite/scheme
// 百度主板 universal link 地址：
// https://boxer.baidu.com/scheme
// https://boxer2.baidu.com/scheme

// 百度极速版 schema 头：baiduboxlite
// 百度主板 schema 头：baiduboxapp

// App Store 的 schema 和 universal link
// schema：
// itms-apps://itunes.apple.com/app/id382201985
// itms-apps://apps.apple.com/app/id382201985

// itms-apps://itunes.apple.com/cn/app/id382201985
// itms-apps://apps.apple.com/cn/app/id382201985

// universal link：
// https://itunes.apple.com/app/id382201985
// https://apps.apple.com/app/id382201985

// https://itunes.apple.com/cn/app/id382201985
// https://apps.apple.com/cn/app/id382201985

#define schema_value @"https://itunes.apple.com/cn/app/id382201985"
#define universal_link_value @"itms-apps://itunes.apple.com/cn/app/id382201985"

@implementation PBOpenURLController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *schemaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:schemaBtn];
    schemaBtn.frame = CGRectMake(50, 150, 100, 50);
    schemaBtn.layer.borderColor = [UIColor redColor].CGColor;
    schemaBtn.layer.borderWidth = 1.112;
    [schemaBtn setTitle:@"schema 方式打开「百度」" forState:UIControlStateNormal];
    [schemaBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    schemaBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [schemaBtn addTarget:self action:@selector(schemaBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *uLinkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:uLinkBtn];
    uLinkBtn.frame = CGRectMake(200, 150, 100, 50);
    uLinkBtn.layer.borderColor = [UIColor redColor].CGColor;
    uLinkBtn.layer.borderWidth = 1.112;
    [uLinkBtn setTitle:@"universal link 方式打开「百度」" forState:UIControlStateNormal];
    [uLinkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    uLinkBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [uLinkBtn addTarget:self action:@selector(uLinkBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)isInstalled:(NSURL *)schema {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:schema]) {
        NSLog(@"「百度」已安装，并且已将「百度」添加到主调 App 的 schema 头白名单！");
        return YES;
    } else {
        NSLog(@"「百度」未安装，或者「百度」已安装但是没有将「百度」添加到主调 App 的 schema 头白名单");
        return NO;
    }
}

- (void)schemaBtnOnClick:(UIButton *)btn {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *schema = [NSURL URLWithString:@"baiduboxapp://"];
    NSLog(@"isInstalled = %d", [self isInstalled:schema]);
    [application openURL:schema options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"打开成功");
        } else {
            NSLog(@"打开失败");
            // 1. schema 格式不正确
            // 2. 「百度」未安装
            // 3. 用户取消了系统弹窗
            
            // schema 方式
            NSURL *downloadSchema = [NSURL URLWithString:universal_link_value];
            // universal link 方式
            //NSURL *downloadSchema = [NSURL URLWithString:schema_value];
            [application openURL:downloadSchema options:@{} completionHandler:^(BOOL success) {
                NSLog(@"success = %d", success);
            }];
        }
    }];
}

- (void)uLinkBtnOnClick:(UIButton *)btn {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *schema = [NSURL URLWithString:@"https://boxer.baidu.com/scheme"];
    [application openURL:schema options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"打开成功");
            // 1. 如果「百度」已安装，则打开「百度」
            // 2. 如果「百度」未安装，则打开 Safari 浏览器访问当前页
            // 2.1 将当前页设置为「下载中间页」，用户点击下载按钮跳转至 App Store 下载
            // 2.2 将当前页设置为「下载中间页」，用户加载网页时自动跳转至 App Store 下载
            // 3. 网页里的下载行为可以是 schema 方式，也可以是 universal link 方式
            // 3.1 schema 方式：点击网页下载按钮，href 跳转至 universal_link_value（宏）
            // 3.2 universal link 方式：点击网页下载按钮，href 跳转至 schema_value（宏）
            // 3.3 App Store 这款官方应用肯定是同时支持 schema 方式和 universal link 方式的。
        } else {
            NSLog(@"打开失败");
            // 1. schema 格式不正确
        }
    }];
}

@end
