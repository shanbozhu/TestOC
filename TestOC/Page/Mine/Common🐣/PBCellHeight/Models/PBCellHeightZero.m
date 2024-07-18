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
        
        // 所有键全部赋值：所有键对应的值全部赋值给与键同名的私有成员变量当中
        [self setValuesForKeysWithDictionary:dict];
        
        // 特殊处理模型对象中数据类型为数组的成员变量
        NSMutableArray *dataArr = [NSMutableArray array];
        for (NSDictionary *dic in self.data) {
            PBCellHeightZeroData *testListData = [PBCellHeightZeroData testListDataWithDict:dic];
            [dataArr addObject:testListData];
        }
        self.data = dataArr;
    }
    return self;
}

// 调用setValuesForKeysWithDictionary:方法时，下面方法实现不能缺少
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (void)dealloc {
    NSLog(@"PBCellHeightZero对象被释放了");
}

@end
