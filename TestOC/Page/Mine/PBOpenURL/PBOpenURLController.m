//
//  PBOpenURLController.m
//  TestOC
//
//  Created by zhushanbo on 2026/5/23.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBOpenURLController.h"
#import <SafariServices/SafariServices.h>

@interface PBOpenURLController () <SFSafariViewControllerDelegate>

@end

// 百度极速版活动页
// https://activity.baidu.com/mbox/4a81aa9860/staticMiddlePage_3?appname=baiduboxlite
// https://activity.baidu.com/mbox/4a81a89b62/defaultNewsPage_1?appname=baiduboxlite&vid=3185394484734977936&channel=bd-sem&channel_id=1021077d&invoke_id=1020204t&query%3D

// 百度主板 universal link 服务器配置：https://boxer.baidu.com/apple-app-site-association
// 百度极速版 universal link 服务器配置：https://wakeup.baidu.com/apple-app-site-association

// 百度主板 universal link
#define baiduboxapp_universal_link @"https://boxer.baidu.com/scheme"
// 百度极速版 universal link
#define baiduboxlite_universal_link @"https://wakeup.baidu.com/baiduboxlite/scheme"

// 百度主板 schema
#define baiduboxapp_schema @"baiduboxapp://"
// 百度极速版 schema
#define baiduboxlite_schema @"baiduboxlite://"

// App Store 的 universal link
#define appstore_universal_link @"https://itunes.apple.com/cn/app/id382201985"
#define appstore_universal_link1 @"https://apps.apple.com/cn/app/id382201985"
// App Store 的 schema
#define appstore_schema @"itms-apps://itunes.apple.com/cn/app/id382201985"
#define appstore_schema1 @"itms-apps://apps.apple.com/cn/app/id382201985"

// SFSafariViewController 仅支持 HTTP/HTTPS URL
#define safari_demo_url @"https://www.baidu.com"

// 从 App Store 查询应用信息
// https://itunes.apple.com/lookup?id=1281873118

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
    
    UIButton *uLinkBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:uLinkBtn1];
    uLinkBtn1.frame = CGRectMake(50, 250, 100, 50);
    uLinkBtn1.layer.borderColor = [UIColor redColor].CGColor;
    uLinkBtn1.layer.borderWidth = 1.112;
    [uLinkBtn1 setTitle:@"universal link 方式打开「百度 1」" forState:UIControlStateNormal];
    [uLinkBtn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    uLinkBtn1.titleLabel.font = [UIFont systemFontOfSize:12];
    [uLinkBtn1 addTarget:self action:@selector(uLinkBtnOnClick1:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *uLinkBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:uLinkBtn2];
    uLinkBtn2.frame = CGRectMake(200, 250, 100, 50);
    uLinkBtn2.layer.borderColor = [UIColor redColor].CGColor;
    uLinkBtn2.layer.borderWidth = 1.112;
    [uLinkBtn2 setTitle:@"universal link 方式打开「百度 2」" forState:UIControlStateNormal];
    [uLinkBtn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    uLinkBtn2.titleLabel.font = [UIFont systemFontOfSize:12];
    [uLinkBtn2 addTarget:self action:@selector(uLinkBtnOnClick2:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *safariBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:safariBtn];
    safariBtn.frame = CGRectMake(50, 350, 250, 50);
    safariBtn.layer.borderColor = [UIColor redColor].CGColor;
    safariBtn.layer.borderWidth = 1.112;
    [safariBtn setTitle:@"SFSafariViewController 打开网页" forState:UIControlStateNormal];
    [safariBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    safariBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [safariBtn addTarget:self action:@selector(safariBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark - 事件

- (void)schemaBtnOnClick:(UIButton *)btn {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *schema = [NSURL URLWithString:baiduboxapp_schema];
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
            //NSURL *downloadSchema = [NSURL URLWithString:appstore_schema];
            // universal link 方式
            NSURL *downloadSchema = [NSURL URLWithString:appstore_universal_link];
            [application openURL:downloadSchema options:@{} completionHandler:^(BOOL success) {
                NSLog(@"success = %d", success);
            }];
        }
    }];
}

- (void)uLinkBtnOnClick:(UIButton *)btn {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *schema = [NSURL URLWithString:baiduboxapp_universal_link];
    [application openURL:schema options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"打开成功");
            // 1. 如果「百度」已安装，则打开「百度」
            // 2. 如果「百度」未安装，则打开 Safari 浏览器访问当前网页
            // 2.1 将当前网页设置为「下载中间页」，用户点击下载按钮跳转至 App Store 下载
            // 2.2 将当前网页设置为「下载中间页」，用户加载网页时自动跳转至 App Store 下载
            // 3. 网页里的下载行为可以是 schema 方式，也可以是 universal link 方式
            // 3.1 schema 方式：点击网页下载按钮，href 跳转至 appstore_schema
            // 3.2 universal link 方式：点击网页下载按钮，href 跳转至 appstore_universal_link
            // 3.3 App Store 这款官方应用肯定是同时支持 schema 方式和 universal link 方式
        } else {
            NSLog(@"打开失败");
            // 1. universal link 格式不正确
        }
    }];
}

- (void)uLinkBtnOnClick1:(UIButton *)btn {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *schema = [NSURL URLWithString:baiduboxapp_universal_link];
    NSDictionary *options = @{
        UIApplicationOpenURLOptionUniversalLinksOnly : @(YES)
    };
    [application openURL:schema options:options completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"打开成功");
        } else {
            NSLog(@"打开失败");
            // 1. universal link 无法调起 App
        }
    }];
}

- (void)uLinkBtnOnClick2:(UIButton *)btn {
//    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:appstore_universal_link]];
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:baiduboxapp_universal_link]];
    [self presentViewController:safariViewController animated:YES completion:nil];
}

- (void)safariBtnOnClick:(UIButton *)btn {
    NSURL *URL = [NSURL URLWithString:safari_demo_url];
    SFSafariViewControllerConfiguration *configuration = [[SFSafariViewControllerConfiguration alloc] init];
    configuration.entersReaderIfAvailable = NO;
    configuration.barCollapsingEnabled = YES;

    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:URL configuration:configuration];
    safariViewController.delegate = self;
    safariViewController.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleClose;
    safariViewController.preferredBarTintColor = [UIColor whiteColor];
    safariViewController.preferredControlTintColor = [UIColor blueColor];
    [self presentViewController:safariViewController animated:YES completion:nil];
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    NSLog(@"SFSafariViewController 已关闭");
}

- (void)safariViewController:(SFSafariViewController *)controller initialLoadDidRedirectToURL:(NSURL *)URL {
    NSLog(@"SFSafariViewController 首次加载发生重定向：%@", URL.absoluteString);
}

@end
