//
//  PBCellHeightFiveCellVM.h
//  TestOC
//
//  Created by shanbo on 2022/6/6.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBCellHeightZero.h"

NS_ASSUME_NONNULL_BEGIN

#define labFont 15

@interface PBCellHeightFiveCellVM : NSObject

@property (nonatomic, assign) CGRect labRect;
@property (nonatomic, assign) CGRect imageViewRect;
@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, strong) PBCellHeightZeroData *testListData;

- (void)layoutInfoWithData:(PBCellHeightZeroData *)testListData;

@end

NS_ASSUME_NONNULL_END
