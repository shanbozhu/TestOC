//
//  PBListTwoController.m
//  PBHome
//
//  Created by DaMaiIOS on 17/10/8.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBListTwoController.h"
#import "PBListThreeController.h"

@interface PBListTwoController ()

@end

@implementation PBListTwoController

//- (BOOL)pb_panGestureRecognizerEnabled {
//    return NO;
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationItem.hidesBackButton = YES;
    //self.tabBarController.navigationItem.title = @"two";
    self.navigationItem.title = @"two";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(100, 100, [UIScreen mainScreen].bounds.size.width-200, 40);
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
}

- (void)btnClick:(UIButton *)btn {
    PBListThreeController *vc = [[PBListThreeController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    //[self.tabBarController.navigationController pushViewController:vc animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}

@end
