//
//  PBCellHeightFiveCellVM.h
//  TestOC
//
//  Created by shanbo on 2022/6/6.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 字体
#define labFont 15

@class PBCellHeightZeroData;
@interface PBCellHeightFiveCellVM : NSObject

@property (nonatomic, assign) CGRect labRect; // 标题的frame
@property (nonatomic, assign) CGRect imageViewRect; // 图片的frame
@property (nonatomic, assign) CGFloat cellHeight; // cell的高度

- (void)layoutInfoWithData:(PBCellHeightZeroData *)testListData;

@end

NS_ASSUME_NONNULL_END
