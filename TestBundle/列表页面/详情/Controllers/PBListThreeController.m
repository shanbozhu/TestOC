//
//  PBListThreeController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/10/23.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBListThreeController.h"
#import "PBListFourController.h"

@implementation PBListThreeController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backClick:)];
    
    //self.navigationItem.hidesBackButton = YES;
    //self.tabBarController.navigationItem.title = @"three";
    self.navigationItem.title = @"three";
}

- (void)backClick:(UIBarButtonItem *)btn {
    // 返回到指定[控制器]
    PBListFourController *vc = [[PBListFourController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [arr removeLastObject];
    [arr addObject:vc];
    [arr addObject:self.navigationController.viewControllers.lastObject];
    self.navigationController.viewControllers = arr;
    
    [self.navigationController popViewControllerAnimated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
    
    /** 返回到指定[标签控制器]
    UITabBarController *tab = self.navigationController.viewControllers[0];
    tab.selectedIndex = 1;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
     */
}

@end
