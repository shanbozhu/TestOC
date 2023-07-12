//
//  PBCycleCollectionView.h
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBCellHeightZero.h"

NS_ASSUME_NONNULL_BEGIN

/// 滚动方向
typedef enum : NSUInteger {
    PBScrollDirectionHorizontal = 0, ///< 横向
    PBScrollDirectionVertical = 1, ///< 竖向
} PBScrollDirection;

@interface PBCycleCollectionView : UIView

@property (nonatomic, strong) PBCellHeightZero *testList;

// 自动翻页 默认 NO
@property (nonatomic, assign) BOOL autoPage;

- (instancetype)initWithFrame:(CGRect)frame scrollDirection:(PBScrollDirection)scrollDirection;

@end

NS_ASSUME_NONNULL_END
