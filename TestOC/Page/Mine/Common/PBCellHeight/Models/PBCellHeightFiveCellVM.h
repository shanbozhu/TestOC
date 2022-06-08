//
//  PBCellHeightFiveCellVM.h
//  TestOC
//
//  Created by shanbo on 2022/6/6.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBCellHeightZero.h"
#import "PBCellHeightFiveCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBCellHeightFiveCellVM : NSObject

@property (nonatomic, assign) CGFloat cellHeight;

- (void)layoutInfoWithData:(PBCellHeightZeroData *)testListData;
- (void)configureCell:(PBCellHeightFiveCell *)cell;

@end

NS_ASSUME_NONNULL_END
