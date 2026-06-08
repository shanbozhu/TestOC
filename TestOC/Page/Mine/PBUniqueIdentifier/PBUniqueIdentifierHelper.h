//
//  PBUniqueIdentifierHelper.h
//  TestOC
//
//  Created by zhushanbo on 2026/6/8.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBUniqueIdentifierItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBUniqueIdentifierHelper : NSObject

/// 创建全部方案条目（标识值初始为「加载中...」）
+ (NSArray<PBUniqueIdentifierItem *> *)allSchemeItems;

/// 刷新全部标识值
+ (void)refreshAllIdentifiersForItems:(NSArray<PBUniqueIdentifierItem *> *)items
                           completion:(void (^)(void))completion;

/// 刷新单个方案
+ (void)refreshIdentifierForItem:(PBUniqueIdentifierItem *)item
                      completion:(nullable void (^)(void))completion;

/// 请求 IDFA 授权（ATT），授权完成后回调
+ (void)requestIDFAAuthorizationWithCompletion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
