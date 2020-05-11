//
//  PBTestEspressos.h
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>
#import "PBTestEspressosSeatCon.h"

@interface PBTestEspressos : NSObject<YYModel>

@property (nonatomic, strong) PBTestEspressosSeatCon *seatContainer; //dict

// 下面属性自己添加的
@property (nonatomic, strong) NSArray *seats; // 所有座位数组
@property (nonatomic, strong) NSArray *seatsRowN; // 所有行号数组
@property (nonatomic, assign) NSInteger maxColCount; // 最大列数

@end
