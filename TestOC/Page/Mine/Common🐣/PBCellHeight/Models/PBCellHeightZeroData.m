//
//  PBCellHeightZeroData.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightZeroData.h"
#import "PBCellHeightFiveCell.h"

@implementation PBCellHeightZeroData

+ (id)testListDataWithDict:(NSDictionary *)dict {
    return [[self alloc]initWithDict:dict];
}

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        
        [self setValuesForKeysWithDictionary:dict];
        
        // 必选        
        // 在子线程，提前计算好各控件的frame
        [PBCellHeightFiveCell calculateLayoutWithViewModel:self preferredSize:CGSizeZero];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (NSMutableDictionary *)layoutInfoMutDic {
    if (!_layoutInfoMutDic) {
        _layoutInfoMutDic = [NSMutableDictionary dictionary];
    }
    return _layoutInfoMutDic;
}

- (void)dealloc {
    NSLog(@"PBCellHeightZeroData对象被释放了");
}

@end
