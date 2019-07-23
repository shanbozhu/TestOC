//
//  PBSeatSelectionView.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/8.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBTestEspressos.h"

@interface PBSeatSelectionView : UIView

@property (nonatomic, strong) PBTestEspressos *testEspressos;

+ (id)seatSelectionViewWithFrame:(CGRect)frame;

@end
