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

//刷新状态
enum RefreshStatus {
    RefreshStatusHeader,
    RefreshStatusFooter,
};
typedef enum RefreshStatus kPBRefreshStatus;

@interface PBRefresh : NSObject

@property (nonatomic, copy) PBRefreshHeaderBlock headerBlock;
@property (nonatomic, copy) PBRefreshFooterBlock footerBlock;

+ (MJRefreshHeader *)refreshHeaderWithTarget:(id)target refreshingBlock:(PBRefreshHeaderBlock)headerBlock;
+ (MJRefreshFooter *)refreshFooterWithTarget:(id)target refreshingBlock:(PBRefreshFooterBlock)footerBlock;

@end
