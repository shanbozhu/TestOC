//
//  PBTestEspressosSeatCon.m
//  TestOC
//
//  Created by DaMaiIOS on 17/8/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestEspressosSeatCon.h"

@implementation PBTestEspressosSeatCon

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"seatList":[PBTestEspressosSCSeatList class]};
}

@end
