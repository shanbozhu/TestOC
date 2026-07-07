//
//  PBHomeController.m
//  PBHome
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBHomeController.h"
// menta 广告测试代码
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>

@interface PBHomeController ()

@property (nonatomic, strong) NSArray<MUVidEarnAdObject *> *adObjects;

@end

@implementation PBHomeController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"首页";
    self.tabBarController.navigationController.navigationBar.barTintColor = [UIColor redColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // menta 广告测试代码
    MUVidEarnAdObject *adObject = [[MUVidEarnAdObject alloc] init];
    adObject.task.btnTitle = @"haoa";
    [adObject.task btnTitle];
}

@end
