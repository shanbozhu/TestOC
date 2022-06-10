//
//  PBCellHeightZeroData.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightZeroData.h"

@implementation PBCellHeightZeroData

+ (id)testListDataWithDict:(NSDictionary *)dict {
    return [[self alloc]initWithDict:dict];
}

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        
        [self setValuesForKeysWithDictionary:dict];
        
        // required
        self.fiveCellVM = [[PBCellHeightFiveCellVM alloc] init];
        [self.fiveCellVM layoutInfoWithData:self]; // 提前计算好各控件的frame
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (void)dealloc {
    NSLog(@"PBCellHeightZeroData对象被释放了");
}

@end
