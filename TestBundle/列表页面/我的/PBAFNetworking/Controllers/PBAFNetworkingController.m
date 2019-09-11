//
//  PBAFNetworkingController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAFNetworkingController.h"
#import "PBAFNetworkingZeroController.h"
#import "PBAFNetworkingTwoController.h"

@interface PBAFNetworkingController ()

@end

@implementation PBAFNetworkingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 40);
    [btn setTitle:@"点我返回Json" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.backgroundColor = [UIColor grayColor];
    btn.tag = 0;
    
    UIButton *twoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:twoBtn];
    twoBtn.frame = CGRectMake(20, 150, [UIScreen mainScreen].bounds.size.width-40, 40);
    [twoBtn setTitle:@"点我下载文件,支持断点续传和离线下载" forState:UIControlStateNormal];
    [twoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    twoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    twoBtn.backgroundColor = [UIColor grayColor];
    twoBtn.tag = 2;
}

- (void)btnClick:(UIButton *)btn {
    if (btn.tag == 0) {
        PBAFNetworkingZeroController *testListController = [[PBAFNetworkingZeroController alloc]init];
        testListController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    }
    if (btn.tag == 2) {
        PBAFNetworkingTwoController *testListTwoController = [[PBAFNetworkingTwoController alloc]init];
        testListTwoController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testListTwoController animated:YES];
        testListTwoController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
