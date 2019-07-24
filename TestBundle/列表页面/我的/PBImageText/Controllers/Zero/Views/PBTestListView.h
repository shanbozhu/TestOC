//
//  PBTestListView.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBTestZeroEspressos.h"

@interface PBTestListView : UIView

@property (nonatomic, strong) PBTestZeroEspressos *testEspressos;

+ (id)testListView;

@end
