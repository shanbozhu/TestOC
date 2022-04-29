//
//  PBAllWelfareController.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/6/2.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import "PBAllWelfareController.h"
#import "PBChannelHeaderView.h"
#import "PBChannelContentView.h"
#import "PBWelfareController.h"

@interface PBAllWelfareController ()<PBChannelContentViewDelegate, PBChannelHeaderViewDelegate>

@property (nonatomic, weak) PBChannelHeaderView *channelHeaderView;
@property (nonatomic, weak) PBChannelContentView *channelContentView;

@end

@implementation PBAllWelfareController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    self.title = @"我的福利";
    
    // 头部
    PBChannelHeaderView *channelHeaderView = [PBChannelHeaderView channelView];
    self.channelHeaderView = channelHeaderView;
    [self.view addSubview:channelHeaderView];
    channelHeaderView.frame = CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, 40);
    
    channelHeaderView.channelArr = @[@"哈哈", @"哈哈哈哈哈哈", @"哈哈哈哈", @"哈哈", @"哈哈哈哈", @"哈哈", @"哈哈", @"哈哈哈哈哈哈哈哈哈哈哈", @"哈哈哈哈", @"哈哈", @"哈哈哈哈", @"哈哈"];
    
    channelHeaderView.delegate = self;
    
    // 内容
    PBChannelContentView *channelContentView = [PBChannelContentView channelContentViewWithFrame:CGRectMake(0, CGRectGetMaxY(channelHeaderView.frame), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-CGRectGetHeight(channelHeaderView.frame) - 64)];
    self.channelContentView = channelContentView;
    [self.view addSubview:channelContentView];
    channelContentView.channelArr = channelHeaderView.channelArr;
    channelContentView.delegate = self;
}

// delegate
- (void)channelView:(PBChannelHeaderView *)channelView andIndex:(NSInteger)index {
    // 点击头部,设置内容偏移量
    [self.channelContentView setContentOffsetWithIndex:index];
}

- (void)channelContentView:(PBChannelContentView *)channelContentView andOffset:(CGPoint)offset {
    // 拖动内容,设置头部偏移量
    [self.channelHeaderView setContentOffsetWithOffset:offset];
}

// DataSource
- (UIViewController *)channelContentView:(PBChannelContentView *)channelContentView andPageView:(UIView *)pageView andIndex:(NSInteger)index {
    if (index % 2 == 0) {
        PBWelfareController *welfareController = [[PBWelfareController alloc] init];
        
        [self addChildViewController:welfareController];
        [pageView addSubview:welfareController.view];
        welfareController.view.backgroundColor = [UIColor lightGrayColor];
        return welfareController;
    } else {
        PBWelfareController *welfareController = [[PBWelfareController alloc] init];
        
        [self addChildViewController:welfareController];
        [pageView addSubview:welfareController.view];
        welfareController.view.backgroundColor = [UIColor grayColor];
        return welfareController;
    }
}

@end
