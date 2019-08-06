//
//  PBUniversalLinkListController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBUniversalLinkListController.h"
#import "YYFPSLabel.h"


@interface PBUniversalLinkListController ()


@end

@implementation PBUniversalLinkListController

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *lab = [[UILabel alloc]init];
    [self.view addSubview:lab];
    lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 80);
    lab.font = [UIFont systemFontOfSize:20];
    lab.textColor = [UIColor blackColor];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = self.content;
}

@end
