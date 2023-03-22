//
//  PBSeatSelectionView.h
//  TestOC
//
//  Created by DaMaiIOS on 17/8/8.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBTestEspressos.h"

#define kPBDaMaiMode YES // 支持[大麦样式]和[猫眼样式]

@interface PBSeatSelectionView : UIView

@property (nonatomic, strong) PBTestEspressos *testEspressos;

+ (id)seatSelectionViewWithFrame:(CGRect)frame;

@end
