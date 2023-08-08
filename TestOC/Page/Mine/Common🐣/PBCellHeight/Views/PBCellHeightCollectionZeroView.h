//
//  PBCellHeightCollectionZeroView.h
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBCellHeightZero.h"
#import "PBCellHeightCollectionBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBCellHeightCollectionZeroView : PBCellHeightCollectionBaseView

@property (nonatomic, strong) PBCellHeightZero *testList;

+ (id)testListView;

@end

NS_ASSUME_NONNULL_END
