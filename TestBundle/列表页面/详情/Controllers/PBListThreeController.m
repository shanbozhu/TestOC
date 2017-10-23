//
//  PBListThreeController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/10/23.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBListThreeController.h"

@implementation PBListThreeController



-(void)viewWillAppear:(BOOL)animated {
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

-(void)backClick:(UIBarButtonItem *)btn {
    //[self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
}

@end
