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

@interface PBCycleCollectionView : UIView

@property (nonatomic, strong) PBCellHeightZero *testList;

+ (id)testListView;

@end

NS_ASSUME_NONNULL_END
