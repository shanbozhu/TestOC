//
//  PBMasonryController.m
//  TestOC
//
//  Created by shanbo on 2022/5/7.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBMasonryController.h"
#import <Masonry.h>

/**
 // 添加约束
 - (NSArray *)mas_makeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block;
 
 // 更新(某一个)约束
 - (NSArray *)mas_updateConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block;
 
 // 重新添加约束
 - (NSArray *)mas_remakeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block;
 
 equalTo()       参数是对象类型,一般是视图对象或者mas_width这样的坐标系对象
 mas_equalTo()   和上面功能相同,除了上面支持的参数外,还可以传递基本类型数据
 
 offset()        参数是基本类型,一般是偏移量;上、左是正数,下、右是负数
 mas_offset()    和上面功能相同,除了上面支持的参数外,还可以传递对象类型数据
 */

@interface PBMasonryController ()

@end

@implementation PBMasonryController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] init];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(200);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];
    label.layer.borderColor = [UIColor redColor].CGColor;
    label.layer.borderWidth = 1.1;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(label);
        make.top.equalTo(label.mas_bottom).offset(100);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];
    button.layer.borderColor = [UIColor redColor].CGColor;
    button.layer.borderWidth = 1.1;
    [button setTitle:@"点击更新约束" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)btnClick:(UIButton *)btn {
    [btn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 100));
    }];
}

@end
