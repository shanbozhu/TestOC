//
//  PBMineController.m
//  PBMine
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBMineController.h"
#import <YYText/YYText.h>
#import "PBListController.h"

@interface PBMineController ()

@end

@implementation PBMineController

-(BOOL)pb_navigationBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"self.view.frame.size.height = %lf", self.view.frame.size.height);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    //imageView
    UIImageView *imageView = [[UIImageView alloc]init];
    [self.view addSubview:imageView];
    imageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-20)/2.0, 200, 20, 20);
    imageView.image = [UIImage imageNamed:@"pbmine_circle"];
    
    //YYLabel
    YYLabel *lab = [[YYLabel alloc]init];
    [self.view addSubview:lab];
    lab.frame = CGRectMake(20, 250, [UIScreen mainScreen].bounds.size.width-40, 20);
    lab.font = [UIFont systemFontOfSize:15];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"点我";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.view addGestureRecognizer:tap];
}

-(void)tapClick:(UITapGestureRecognizer *)tap {
    NSLog(@"我要准备跳转了");
    
    PBListController *tvc = [[PBListController alloc]init];
    tvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tvc animated:YES];
    tvc.view.backgroundColor = [UIColor whiteColor];
}





@end
