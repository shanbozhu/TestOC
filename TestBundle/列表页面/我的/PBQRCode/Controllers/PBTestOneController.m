//
//  PBTestOneController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/25.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestOneController.h"

@interface PBTestOneController ()

@property (nonatomic, weak) UILabel *lab;

@end

@implementation PBTestOneController

- (void)setDesc:(NSString *)desc {
    _desc = desc;
    
    self.lab.text = self.desc;
    [self.lab sizeToFit];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *lab = [[UILabel alloc]init];
    self.lab = lab;
    [self.view addSubview:lab];
    lab.numberOfLines = 0;
    lab.font = [UIFont systemFontOfSize:15];
    lab.frame = CGRectMake(100, 100, [UIScreen mainScreen].bounds.size.width-100-100, 0);
}

@end
