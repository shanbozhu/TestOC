//
//  PBAPortalPodController.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/21.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBAPortalPodController.h"

@interface PBAPortalPodController ()

@end

@implementation PBAPortalPodController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *homeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:homeBtn];
    homeBtn.frame = CGRectMake(50, 150, 100, 50);
    [homeBtn addTarget:self action:@selector(homeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [homeBtn setTitle:@"首页" forState:UIControlStateNormal];
    [homeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    homeBtn.layer.borderColor = [UIColor redColor].CGColor;
    homeBtn.layer.borderWidth = 1.112;
    
    UIButton *mineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:mineBtn];
    mineBtn.frame = CGRectMake(200, 150, 100, 50);
    [mineBtn addTarget:self action:@selector(mineBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [mineBtn setTitle:@"我的" forState:UIControlStateNormal];
    [mineBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    mineBtn.layer.borderColor = [UIColor redColor].CGColor;
    mineBtn.layer.borderWidth = 1.112;
}

- (void)homeBtnClick:(UIButton *)btn {
    // Controller
    Class vc1Class = NSClassFromString(@"PBHomeSDKController");
    UIViewController *vc1 = [[vc1Class alloc]init];
    vc1.view.backgroundColor = [UIColor whiteColor];
    vc1.title = @"首页";
    
    [self.navigationController pushViewController:vc1 animated:YES];
}

- (void)mineBtnClick:(UIButton *)btn {
    Class vc2Class = NSClassFromString(@"PBMineSDKController");
    UIViewController *vc2 = [[vc2Class alloc]init];
    vc2.view.backgroundColor = [UIColor whiteColor];
    vc2.title = @"我的";
    
    [self.navigationController pushViewController:vc2 animated:YES];
}

@end
