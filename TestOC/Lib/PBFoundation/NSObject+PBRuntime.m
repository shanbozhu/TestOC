//
//  NSObject+PBRuntime.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/12.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "NSObject+PBRuntime.h"
#import <objc/runtime.h>

@implementation NSObject (PBRuntime)

#pragma mark - 获取类的所有属性

- (NSArray *)pb_propertyList {
    NSMutableArray *propertyList = [NSMutableArray array];
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar var = ivarList[i];
        
        const char *varName = ivar_getName(var);
        NSString *name = [NSString stringWithUTF8String:varName];
        
        NSString *property = [name substringFromIndex:1];
        [propertyList addObject:property];
    }
    free(ivarList);
    return propertyList;
}

@end
