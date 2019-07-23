//
//  PBSeatsView.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBTestEspressos.h"
#import "PBSeatButton.h"

@class PBSeatsView;
@protocol PBSeatsViewDelegate <NSObject>

- (void)seatsView:(PBSeatsView *)seatsView andSeatBtn:(PBSeatButton *)seatBtn;

@end

@interface PBSeatsView : UIView

@property (nonatomic, assign) CGFloat seatBtnWidth;
@property (nonatomic, assign) CGFloat seatBtnHeight;

@property (nonatomic, weak) id<PBSeatsViewDelegate> delegate;

@property (nonatomic, strong) PBTestEspressos *testEspressos;

+ (id)seatsView;

@end
