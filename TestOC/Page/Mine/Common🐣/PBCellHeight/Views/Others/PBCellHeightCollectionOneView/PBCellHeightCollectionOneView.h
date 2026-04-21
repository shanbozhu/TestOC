//
//  PBCellHeightCollectionOneView.h
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBCellHeightZero.h"
#import "PBCellHeightCollectionBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class PBCellHeightCollectionOneView;
@protocol PBCellHeightCollectionOneViewDelegate <NSObject>

- (void)cellHeightCollectionOneView:(PBCellHeightCollectionOneView *)CellHeightCollectionOneView sinceId:(NSInteger)sinceId status:(NSInteger)status;

@end

@interface PBCellHeightCollectionOneView : PBCellHeightCollectionBaseView

@property (nonatomic, strong) PBCellHeightZero *testList;
@property (nonatomic, weak) id<PBCellHeightCollectionOneViewDelegate> delegate;

+ (id)testListView;

@end

NS_ASSUME_NONNULL_END
