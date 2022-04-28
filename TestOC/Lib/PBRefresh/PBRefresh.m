//
//  PBRefresh.m
//  陪伴Ta
//
//  Created by DaMaiIOS on 16/7/21.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBRefresh.h"

@interface PBRefresh ()

@end

@implementation PBRefresh

+ (id)refreshHeaderWithRefreshingTarget:(id)target {
    PBRefresh *refresh = [[self alloc] init];
    [refresh refreshHeader];
    return refresh.header;
}

+ (id)refreshFooterWithRefreshingTarget:(id)target {
    PBRefresh *refresh = [[self alloc] init];
    [refresh refreshFooter];
    return refresh.footer;
}

- (void)refreshHeader {
    MJRefreshNormalHeader *refreshNormalHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (self.headerBlock != nil) {
            self.headerBlock(self);
        }
        [self.delegate refreshHeader:self];
    }];
    refreshNormalHeader.lastUpdatedTimeLabel.hidden = YES;
    [refreshNormalHeader setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [refreshNormalHeader setTitle:@"释放更新" forState:MJRefreshStatePulling];
    [refreshNormalHeader setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
    refreshNormalHeader.stateLabel.textColor = [UIColor redColor];
    self.header = refreshNormalHeader;
}

-(void)refreshFooter {
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
    
    MJRefreshAutoNormalFooter *refreshAutoNormalFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (self.footerBlock != nil) {
            self.footerBlock(self);
        }
        [self.delegate refreshFooter:self];
    }];
    refreshAutoNormalFooter.refreshingTitleHidden = YES;
    [refreshAutoNormalFooter setTitle:@"" forState:MJRefreshStateIdle];
    [refreshAutoNormalFooter setTitle:@"" forState:MJRefreshStatePulling];
    [refreshAutoNormalFooter setTitle:@"" forState:MJRefreshStateRefreshing];
    [refreshAutoNormalFooter setTitle:@"暂无更多内容" forState:MJRefreshStateNoMoreData];
    refreshAutoNormalFooter.stateLabel.textColor = [UIColor redColor];
    self.footer = refreshAutoNormalFooter;
}

+ (id)refreshHeaderWithRefreshingTarget:(id)target andRefreshingBlock:(PBRefreshHeaderBlock)headerBlock {
    PBRefresh *refresh = [[self alloc]init];
    refresh.headerBlock = headerBlock;
    [refresh refreshHeader];
    // 统一修改不同样式的公共属性
    refresh.header.automaticallyChangeAlpha = YES;
    //[refresh.header beginRefreshing];
    return refresh.header;
}

+ (id)refreshFooterWithRefreshingTarget:(id)target andRefreshingBlock:(PBRefreshFooterBlock)footerBlock {
    PBRefresh *refresh = [[self alloc]init];
    refresh.footerBlock = footerBlock;
    [refresh refreshFooter];
    // 统一修改不同样式的公共属性
    refresh.footer.automaticallyChangeAlpha = YES;
    refresh.footer.automaticallyHidden = YES;
    //[refresh.footer beginRefreshing];
    return refresh.footer;
}

- (void)dealloc {
    NSLog(@"PBRefresh对象被释放了");
}


@end

