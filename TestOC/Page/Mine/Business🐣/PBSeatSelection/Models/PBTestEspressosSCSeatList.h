//
//  PBTestEspressosSCSeatList.h
//  TestOC
//
//  Created by DaMaiIOS on 17/8/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTestEspressosSCSLSeatInfo.h"

@interface PBTestEspressosSCSeatList : NSObject

@property (nonatomic, assign) NSInteger type; // 0过道，1座位，2换行
@property (nonatomic, strong) PBTestEspressosSCSLSeatInfo *seatInfo; // dict

@end
