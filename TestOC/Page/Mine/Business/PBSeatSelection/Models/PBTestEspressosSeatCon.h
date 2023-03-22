//
//  PBTestEspressosSeatCon.h
//  TestOC
//
//  Created by DaMaiIOS on 17/8/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTestEspressosSCSeatList.h"
#import <YYModel/YYModel.h>

@interface PBTestEspressosSeatCon : NSObject<YYModel>

@property (nonatomic, strong) NSArray *taopiaoList;
@property (nonatomic, strong) NSArray *seatList;
@property (nonatomic, strong) NSArray *seatPrice;
@property (nonatomic, copy) NSString *standName;

@end
