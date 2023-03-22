//
//  PBBusinessController.m
//  PBBusiness
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBBusinessController.h"
#import <YYText/YYText.h>
#import "PBBusinessView.h"
#import "PBBusinessController+Click.h"

@interface PBBusinessController ()<PBBusinessViewDelegate>

@end

@implementation PBBusinessController

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
    
    // BusinessView
    PBBusinessView *BusinessView = [PBBusinessView BusinessView];
    [self.view addSubview:BusinessView];
    BusinessView.frame = self.view.bounds;
    BusinessView.delegate = self;
    
    BusinessView.pageArr = self.pageArr;
}

@end
