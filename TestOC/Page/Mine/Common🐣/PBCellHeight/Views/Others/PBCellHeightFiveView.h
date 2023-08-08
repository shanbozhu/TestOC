//
//  PBCellHeightFiveView.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBCellHeightBaseView.h"
#import "PBCellHeightZero.h"

@class PBCellHeightFiveView;
@protocol PBCellHeightFiveViewDelegate <NSObject>

- (void)cellHeightFiveView:(PBCellHeightFiveView *)cellHeightFiveView sinceId:(NSInteger)sinceId status:(NSInteger)status;

@end

@interface PBCellHeightFiveView : PBCellHeightBaseView

@property (nonatomic, strong) PBCellHeightZero *testList;

@property (nonatomic, weak) id<PBCellHeightFiveViewDelegate> delegate;

+ (id)testListFiveView;

@end
