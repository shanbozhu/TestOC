//
//  PBStorageTwoController.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/9/2.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBStorageTwoController.h"
#import "PBSandBox.h"

@interface PBStorageTwoController ()

@end

@implementation PBStorageTwoController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"SandBox";
    self.title = @"SandBox";
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
