//
//  PBCommonController.m
//  PBCommon
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBCommonController.h"
#import <YYText/YYText.h>
#import "PBCommonView.h"
#import "PBCommonController+Click.h"

@interface PBCommonController ()<PBCommonViewDelegate>

@end

@implementation PBCommonController

- (BOOL)pb_navigationBarHidden {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"我的";
    self.tabBarController.navigationController.navigationBar.barTintColor = [UIColor greenColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    // CommonView
    PBCommonView *CommonView = [PBCommonView CommonView];
    [self.view addSubview:CommonView];
    CommonView.frame = self.view.bounds;
    CommonView.delegate = self;
    
    CommonView.pageArr = self.pageArr;
}

@end
