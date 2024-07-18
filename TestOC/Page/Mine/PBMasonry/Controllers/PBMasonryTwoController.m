//
//  PBMasonryTwoController.m
//  TestOC
//
//  Created by shanbo on 2022/5/17.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBMasonryTwoController.h"
#import <Masonry.h>
#import <YYText.h>

@interface PBMasonryTwoController ()

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) MASConstraint *bottom;

@end

@implementation PBMasonryTwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 水平方向滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = UIColor.greenColor;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    // 设置 Scrollview 的约束
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(100);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-100);
    }];
    
    // 设置scrollView的子视图，即过渡视图contentSize
    UIView *contentView = [[UIView alloc] init];
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(scrollView);
        make.height.mas_equalTo(scrollView);
    }];
    
    UIView *previousView = nil;
    for (int i = 0; i < 10; i++) {
        YYLabel *label = [[YYLabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 2;
        label.backgroundColor = UIColor.redColor;
        label.text = [NSString stringWithFormat:@"水平方向\n第 %d 个视图", (i + 1)];
        
        // 添加到父视图，并设置过渡视图中子视图的约束
        [contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentView).offset(20);
            make.bottom.equalTo(contentView).offset(-20);
            make.width.equalTo(scrollView).offset(-40);
            if (previousView) {
                make.left.mas_equalTo(previousView.mas_right).offset(40);
            } else {
                make.left.mas_equalTo(20);
            }
        }];
        previousView = label;
    }
    
    // 设置将影响到scrollView的contentSize
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(previousView.mas_right).offset(20);
    }];
}

@end
