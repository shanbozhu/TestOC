//
//  PBUniversalLinkController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBUniversalLinkController.h"
#import "PBUniversalLinkListController.h"

@interface PBUniversalLinkController ()

@end

@implementation PBUniversalLinkController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showContent:) name:@"Link" object:nil];
    
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:btn];
        btn.frame = CGRectMake(20, 150, [UIScreen mainScreen].bounds.size.width-40, 40);
        [btn setTitle:@"点击打开应用的系统设置" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor grayColor];
        btn.tag = 0;
    }
    
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:btn];
        btn.frame = CGRectMake(20, 200, [UIScreen mainScreen].bounds.size.width-40, 40);
        [btn setTitle:@"点击打开应用PBAPortal" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor grayColor];
        btn.tag = 1;
    }
}

- (void)btnClick:(UIButton *)btn {
    if (btn.tag == 0) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    
    if (btn.tag == 1) {
        // 在iOS9+中canOpenURL:方法打开的URLScheme必须在info.plist中将它们加入白名单LSApplicationQueriesSchemes中
        // 只调用openURL:方法不需要将打开的URLScheme加入白名单LSApplicationQueriesSchemes中
        
        NSURL *urlScheme = [NSURL URLWithString:@"PBAPortalAAA://xxx"];
        if ([[UIApplication sharedApplication]canOpenURL:urlScheme]) {
            [[UIApplication sharedApplication]openURL:urlScheme];
        } else {
            NSLog(@"未安装应用PBAPortal");
        }
    }
}

- (void)showContent:(NSNotification *)noti {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        PBUniversalLinkListController *testListController = [[PBUniversalLinkListController alloc]init];
        testListController.hidesBottomBarWhenPushed = YES;
        
        testListController.content = [NSString stringWithFormat:@"%@", noti.userInfo[@"url"]];
        
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    });
}

@end
