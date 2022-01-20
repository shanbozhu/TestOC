//
//  PBLinkageController.m
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageController.h"
#import "PBLinkageView.h"

// 参考文档:https://oscarwuer.github.io/2018/01/09/ScrollView%E5%B5%8C%E5%A5%97scrollView%EF%BC%8C%E5%A6%82%E4%BD%95%E8%A7%A3%E5%86%B3%E8%81%94%E5%8A%A8%E9%97%AE%E9%A2%98/

@interface PBLinkageController ()

@end

@implementation PBLinkageController

- (BOOL)pb_panGestureRecognizerEnabled {
    return NO;
}

- (BOOL)pb_navigationBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    // backBtn
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:backBtn];
    backBtn.frame = CGRectMake(0, APPLICATION_STATUSBAR_HEIGHT, 80, APPLICATION_NAVIGATIONBAR_CONTENT_HEIGHT);
    backBtn.backgroundColor = [UIColor lightGrayColor];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // linkageView
    PBLinkageView *linkageView = [PBLinkageView linkageView]; // 整个页面就是一个视图
    [self.view addSubview:linkageView];
}

- (void)backBtnClick:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
