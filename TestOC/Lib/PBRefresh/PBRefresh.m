//
//  PBRefresh.m
//  陪伴Ta
//
//  Created by DaMaiIOS on 16/7/21.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBRefresh.h"

@interface PBRefresh ()

@property (nonatomic, weak) MJRefreshHeader *header;
@property (nonatomic, weak) MJRefreshFooter *footer;

@end

@implementation PBRefresh

- (void)refreshHeader {
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
    self.header = refreshNormalHeader;
}

- (void)refreshFooter {
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
    self.footer = refreshAutoNormalFooter;
    
    /**
    MJRefreshBackNormalFooter *refreshBackNormalFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (self.footerBlock != nil) {
            self.footerBlock(self);
        }
        [self.delegate refreshFooter:self];
        
    }];
    refreshBackNormalFooter.refreshingTitleHidden = YES; //修改菊花坐标为居中显示
    [refreshBackNormalFooter setTitle:@"" forState:MJRefreshStateIdle]; //修改提示文字
    [refreshBackNormalFooter setTitle:@"" forState:MJRefreshStatePulling];
    [refreshBackNormalFooter setTitle:@"" forState:MJRefreshStateRefreshing];
    [refreshBackNormalFooter setTitle:@"暂无更多内容" forState:MJRefreshStateNoMoreData];
    refreshBackNormalFooter.stateLabel.textColor = kPBColorWithHexAndAlpha(0x949494, 1);
    self.footer = refreshBackNormalFooter;*/
}

+ (MJRefreshHeader *)refreshHeaderWithTarget:(id)target refreshingBlock:(PBRefreshHeaderBlock)headerBlock {
    PBRefresh *refresh = [[self alloc] init];
    refresh.headerBlock = headerBlock;
    [refresh refreshHeader];
    refresh.header.automaticallyChangeAlpha = YES;
    //[refresh.header beginRefreshing];
    return refresh.header;
}

+ (MJRefreshFooter *)refreshFooterWithTarget:(id)target refreshingBlock:(PBRefreshFooterBlock)footerBlock {
    PBRefresh *refresh = [[self alloc] init];
    refresh.footerBlock = footerBlock;
    [refresh refreshFooter];
    refresh.footer.automaticallyChangeAlpha = YES;
    //[refresh.footer beginRefreshing];
    return refresh.footer;
}

- (void)dealloc {
    NSLog(@"PBRefresh对象被释放了");
}

@end
