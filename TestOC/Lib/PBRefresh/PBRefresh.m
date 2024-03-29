//
//  PBRefresh.m
//  陪伴Ta
//
//  Created by DaMaiIOS on 16/7/21.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBRefresh.h"

@implementation PBRefresh

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (MJRefreshHeader *)refreshHeader {
    __weak typeof(self) weakSelf = self;
    MJRefreshNormalHeader *refreshNormalHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.headerBlock) {
            weakSelf.headerBlock(weakSelf);
        }
    }];
    refreshNormalHeader.lastUpdatedTimeLabel.hidden = YES;
    [refreshNormalHeader setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [refreshNormalHeader setTitle:@"释放更新" forState:MJRefreshStatePulling];
    [refreshNormalHeader setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
    refreshNormalHeader.stateLabel.textColor = [UIColor redColor];
    refreshNormalHeader.automaticallyChangeAlpha = YES;
    //[refreshNormalHeader beginRefreshing];
    
    refreshNormalHeader.layer.borderColor = [UIColor redColor].CGColor;
    refreshNormalHeader.layer.borderWidth = 1.1;
    
    return refreshNormalHeader;
}

- (MJRefreshFooter *)refreshFooter {
    __weak typeof(self) weakSelf = self;
    MJRefreshAutoNormalFooter *refreshAutoNormalFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.footerBlock) {
            weakSelf.footerBlock(weakSelf);
        }
    }];
    refreshAutoNormalFooter.refreshingTitleHidden = YES;
    [refreshAutoNormalFooter setTitle:@"" forState:MJRefreshStateIdle];
    [refreshAutoNormalFooter setTitle:@"" forState:MJRefreshStatePulling];
    [refreshAutoNormalFooter setTitle:@"" forState:MJRefreshStateRefreshing];
    [refreshAutoNormalFooter setTitle:@"暂无更多内容" forState:MJRefreshStateNoMoreData];
    refreshAutoNormalFooter.stateLabel.textColor = [UIColor redColor];
    refreshAutoNormalFooter.automaticallyChangeAlpha = YES;
    //[refreshAutoNormalFooter beginRefreshing];
    
    refreshAutoNormalFooter.layer.borderColor = [UIColor redColor].CGColor;
    refreshAutoNormalFooter.layer.borderWidth = 1.1;
    
    return refreshAutoNormalFooter;
}

+ (MJRefreshHeader *)refreshHeaderWithTarget:(id)target refreshingBlock:(PBRefreshHeaderBlock)headerBlock {
    PBRefresh *refresh = [PBRefresh sharedInstance];
    refresh.headerBlock = headerBlock;
    return [refresh refreshHeader];
}

+ (MJRefreshFooter *)refreshFooterWithTarget:(id)target refreshingBlock:(PBRefreshFooterBlock)footerBlock {
    PBRefresh *refresh = [PBRefresh sharedInstance];
    refresh.footerBlock = footerBlock;
    return [refresh refreshFooter];
}

- (void)dealloc {
    NSLog(@"PBRefresh对象被释放了");
}

@end
