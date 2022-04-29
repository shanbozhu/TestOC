//
//  PBCellHeightZero.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBCellHeightZeroData.h"

@interface PBCellHeightZero : NSObject

@property (nonatomic, strong) NSArray *data; // arr
@property (nonatomic, assign) BOOL dataAddIsNull;

+ (id)testListWithDict:(NSDictionary *)dict;

@end
