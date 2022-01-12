//
//  PBLinkageController.m
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageController.h"
#import "PBLinkageView.h"

@interface PBLinkageController ()

@end

@implementation PBLinkageController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    PBLinkageView *linkageView = [PBLinkageView linkageView]; // 整个页面就是一个视图
    [self.view addSubview:linkageView];
}

@end
