//
//  PBTestEspressosSCSLSeatInfo.h
//  TestOC
//
//  Created by DaMaiIOS on 17/8/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBTestEspressosSCSLSeatInfo : NSObject

@property (nonatomic, assign) NSInteger seatId;
@property (nonatomic, assign) NSInteger x;
@property (nonatomic, copy) NSString *seatNo;
@property (nonatomic, assign) NSInteger y;
@property (nonatomic, copy) NSString *rowNo;
@property (nonatomic, assign) NSInteger tId;
@property (nonatomic, assign) NSInteger fTId;
@property (nonatomic, assign) NSInteger dmPriceId;
@property (nonatomic, assign) NSInteger state; // 0已售，2可选(还可以继续细分不同价格)

@end
