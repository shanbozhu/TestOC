//
//  PBFindController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/23.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBFindController.h"

@implementation PBFindController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"发现";
    self.tabBarController.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

@end
