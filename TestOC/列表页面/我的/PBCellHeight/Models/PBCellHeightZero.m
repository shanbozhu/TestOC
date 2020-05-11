//
//  PBCellHeightZero.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightZero.h"

@implementation PBCellHeightZero

+ (id)testListWithDict:(NSDictionary *)dict {
    return [[self alloc]initWithDict:dict];
}

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        
        [self setValuesForKeysWithDictionary:dict];
        
        NSMutableArray *dataArr = [NSMutableArray array];
        for (NSDictionary *dic in self.data) {
            PBCellHeightZeroData *testListData = [PBCellHeightZeroData testListDataWithDict:dic];
            [dataArr addObject:testListData];
        }
        self.data = dataArr;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
