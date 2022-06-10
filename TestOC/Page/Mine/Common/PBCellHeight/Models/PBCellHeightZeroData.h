//
//  PBCellHeightZeroData.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PBCellHeightFiveCellVM.h"

@interface PBCellHeightZeroData : NSObject

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) PBCellHeightFiveCellVM *fiveCellVM;

+ (id)testListDataWithDict:(NSDictionary *)dict;

@end
