//
//  PBTestController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestController.h"
#import "PBTestListController.h"

@interface PBTestController ()

@end

@implementation PBTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.view addGestureRecognizer:tap];
    
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(100, 200, ([UIScreen mainScreen].bounds.size.width-100)/2, 50);
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.userInteractionEnabled = NO;
}

-(void)tapClick:(UITapGestureRecognizer *)tap {
    
    PBTestListController *testListController = [[PBTestListController alloc]init];
    testListController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:testListController animated:YES];
    testListController.view.backgroundColor = [UIColor whiteColor];
}

@end
