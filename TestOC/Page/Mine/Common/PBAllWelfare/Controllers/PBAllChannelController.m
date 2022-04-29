//
//  PBAllChannelController.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/6/2.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import "PBAllChannelController.h"
#import "PBChannelHeaderView.h"
#import "PBChannelContentView.h"
#import "PBChannelController.h"

@interface PBAllChannelController ()<PBChannelContentViewDelegate, PBChannelHeaderViewDelegate>

@property (nonatomic, weak) PBChannelHeaderView *channelHeaderView;
@property (nonatomic, weak) PBChannelContentView *channelContentView;

@end

@implementation PBAllChannelController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    self.title = @"我的福利";
    
    // 头部
    PBChannelHeaderView *channelHeaderView = [PBChannelHeaderView channelView];
    self.channelHeaderView = channelHeaderView;
    [self.view addSubview:channelHeaderView];
    channelHeaderView.frame = CGRectMake(50, APPLICATION_NAVIGATIONBAR_HEIGHT + 100, [UIScreen mainScreen].bounds.size.width - 100, 40);
    channelHeaderView.channelArr = @[@"哈哈", @"哈哈哈哈哈哈", @"哈哈哈哈", @"哈哈", @"哈哈哈哈", @"哈哈", @"哈哈", @"哈哈哈哈哈哈哈哈哈哈哈", @"哈哈哈哈", @"哈哈", @"哈哈哈哈", @"哈哈"];
    channelHeaderView.delegate = self;
    channelHeaderView.layer.borderColor = [UIColor redColor].CGColor;
    channelHeaderView.layer.borderWidth = 1.1;
    
    // 内容
    PBChannelContentView *channelContentView = [PBChannelContentView channelContentViewWithFrame:CGRectMake(CGRectGetMinX(channelHeaderView.frame), CGRectGetMaxY(channelHeaderView.frame), CGRectGetWidth(channelHeaderView.frame), 400)];
    self.channelContentView = channelContentView;
    [self.view addSubview:channelContentView];
    channelContentView.channelArr = channelHeaderView.channelArr;
    channelContentView.delegate = self;
    channelContentView.layer.borderColor = [UIColor blueColor].CGColor;
    channelContentView.layer.borderWidth = 1.1;
}

// delegate
- (void)channelView:(PBChannelHeaderView *)channelView index:(NSInteger)index {
    // 点击头部,设置内容偏移量
    [self.channelContentView setContentOffsetWithIndex:index];
}

- (void)channelContentView:(PBChannelContentView *)channelContentView offset:(CGPoint)offset {
    // 拖动内容,设置头部偏移量
    [self.channelHeaderView setContentOffsetWithOffset:offset];
}

// dataSource
- (UIViewController *)channelContentView:(PBChannelContentView *)channelContentView pageView:(UIView *)pageView index:(NSInteger)index {
    if (index % 2 == 0) {
        PBChannelController *welfareController = [[PBChannelController alloc] init];
        
        [self addChildViewController:welfareController];
        [pageView addSubview:welfareController.view];
        welfareController.view.backgroundColor = [UIColor lightGrayColor];
        return welfareController;
    } else {
        PBChannelController *welfareController = [[PBChannelController alloc] init];
        
        [self addChildViewController:welfareController];
        [pageView addSubview:welfareController.view];
        welfareController.view.backgroundColor = [UIColor grayColor];
        return welfareController;
    }
}

@end
