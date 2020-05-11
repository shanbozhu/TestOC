//
//  PBMemoryList.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/29.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBMemoryList.h"

@implementation PBMemoryList

// 具有自动内存管理功能的getter和setter
//- (NSString *)name {
//    return _name;
//}
//- (void)setName:(NSString *)name {
//    _name = name;
//}
//
//- (NSInteger)age {
//    return _age;
//}
//- (void)setAge:(NSInteger)age {
//    _age = age;
//}

- (void)dealloc {
    NSLog(@"PBMemoryList对象被释放了");
}

@end
