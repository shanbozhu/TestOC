//
//  PBRefresh.m
//  陪伴Ta
//
//  Created by DaMaiIOS on 16/7/21.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBRefresh.h"

@implementation PBRefresh

- (MJRefreshHeader *)refreshHeader {
    MJRefreshNormalHeader *refreshNormalHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (self.headerBlock) {
            self.headerBlock(self);
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
    MJRefreshAutoNormalFooter *refreshAutoNormalFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (self.footerBlock) {
            self.footerBlock(self);
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
    PBRefresh *refresh = [[self alloc] init];
    refresh.headerBlock = headerBlock;
    return [refresh refreshHeader];
}

+ (MJRefreshFooter *)refreshFooterWithTarget:(id)target refreshingBlock:(PBRefreshFooterBlock)footerBlock {
    PBRefresh *refresh = [[self alloc] init];
    refresh.footerBlock = footerBlock;
    return [refresh refreshFooter];
}

- (void)dealloc {
    NSLog(@"PBRefresh对象被释放了");
}

@end
