//
//  PBMasonryOneController.m
//  TestOC
//
//  Created by shanbo on 2022/5/17.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBMasonryOneController.h"
#import <Masonry.h>
#import <YYText.h>

@interface PBMasonryOneController ()

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) MASConstraint *bottom;

@end

@implementation PBMasonryOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDemo];
}

- (void)createDemo {
    UIView *superView = [[UIView alloc] init];
    superView.backgroundColor = UIColor.greenColor;
    [self.view addSubview:superView];
    [superView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(100);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"增加" forState:UIControlStateNormal];
    button.backgroundColor = UIColor.redColor;
    [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        self.bottom = make.bottom.mas_equalTo(-10); // 记录下这个约束对象
        make.height.equalTo(@(100));
    }];
    
    UIView *blueView = [[UIView alloc] init];
    blueView.backgroundColor = UIColor.blueColor;
    [self.view addSubview:blueView];
    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(superView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(@(100));
    }];
    
    self.superView = superView;
    self.bottomView = button;
}

static int num = 0;
- (void)action:(UIButton *)button {
    // 卸载旧的底部约束
    [self.bottom uninstall];
    
    num += 1;
    YYLabel *view = [[YYLabel alloc] init];
    view.backgroundColor = UIColor.redColor;
    view.text = [NSString stringWithFormat:@"控件%d", num];
    view.textAlignment = NSTextAlignmentCenter;
    view.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    [self.superView addSubview:view];
    
    // 给新 view 添加约束
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.superView.mas_left).offset(10);
        make.top.mas_equalTo(self.bottomView.mas_bottom).offset(10);
        make.right.mas_equalTo(self.superView.mas_right).offset(-10);
        // 添加新的底部约束
        self.bottom = make.bottom.mas_equalTo(self.superView.mas_bottom).offset(-10);
        make.height.equalTo(@(100));
    }];
    self.bottomView = view;
}

@end
