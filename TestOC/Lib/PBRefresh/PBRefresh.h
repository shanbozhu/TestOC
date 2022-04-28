//
//  PBRefresh.h
//  MJRefreshExample
//
//  Created by DaMaiIOS on 16/7/21.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJRefreshHeader.h"
#import "MJRefreshFooter.h"
#import "MJRefresh.h"

@class PBRefresh;
typedef void(^PBRefreshHeaderBlock)(PBRefresh *refresh);
typedef void(^PBRefreshFooterBlock)(PBRefresh *refresh);

@protocol PBRefreshDelegate <NSObject>

- (void)refreshHeader:(PBRefresh *)refresh;
- (void)refreshFooter:(PBRefresh *)refresh;

@end

//刷新状态
enum RefreshStatus {
    RefreshStatusHeader,
    RefreshStatusFooter,
};
typedef enum RefreshStatus kPBRefreshStatus;


@interface PBRefresh : NSObject

@property (nonatomic, weak) id<PBRefreshDelegate> delegate;
@property (nonatomic, strong) PBRefreshHeaderBlock headerBlock;
@property (nonatomic, strong) PBRefreshFooterBlock footerBlock;

@property (nonatomic, weak) MJRefreshHeader *header;
@property (nonatomic, weak) MJRefreshFooter *footer;

+ (id)refreshHeaderWithRefreshingTarget:(id)target;
+ (id)refreshFooterWithRefreshingTarget:(id)target;

+ (id)refreshHeaderWithRefreshingTarget:(id)target andRefreshingBlock:(PBRefreshHeaderBlock)headerBlock;
+ (id)refreshFooterWithRefreshingTarget:(id)target andRefreshingBlock:(PBRefreshFooterBlock)footerBlock;

@end
