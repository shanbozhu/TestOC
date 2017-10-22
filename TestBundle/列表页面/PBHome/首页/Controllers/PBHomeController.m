//
//  PBHomeController.m
//  PBHome
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBHomeController.h"
#import "PBListController.h"

@interface PBHomeController ()

@end

@implementation PBHomeController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"haha";
    //self.navigationItem.title = @"haha";
    
    
    NSLog(@"self.tabBarController = %@", self.tabBarController.navigationController);
    
    self.tabBarController.navigationController.navigationBar.barTintColor = [UIColor redColor];
    //self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    UILabel *lab = [[UILabel alloc]init];
    [self.view addSubview:lab];
    lab.font = [UIFont systemFontOfSize:15];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.frame = CGRectMake(50, 200, [UIScreen mainScreen].bounds.size.width-100, 20);
    lab.text = @"点我吧";
    lab.userInteractionEnabled = YES;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.view addGestureRecognizer:tap];
}

-(void)tapClick:(UITapGestureRecognizer *)tap {
    NSLog(@"我要准备跳转了");
    
    PBListController *tvc = [[PBListController alloc]init];
    tvc.hidesBottomBarWhenPushed = YES;
//    [self.tabBarController.navigationController pushViewController:tvc animated:YES];
    [self.navigationController pushViewController:tvc animated:YES];
    tvc.view.backgroundColor = [UIColor whiteColor];
}

@end
