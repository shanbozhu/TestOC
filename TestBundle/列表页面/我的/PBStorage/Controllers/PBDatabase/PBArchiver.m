//
//  PBArchiver.m
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/17.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBArchiver.h"
#import <objc/runtime.h>

@implementation PBArchiver

// 获取类的所有属性
- (NSArray *)propertyList {
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

// 归档时当前对象需要实现的代理方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *property in [self propertyList]) {
        [aCoder encodeObject:[self valueForKey:property] forKey:property];
    }
}

// 解档时当前对象需要实现的代理方法
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        for (NSString *property in [self propertyList]) {
            [self setValue:[aDecoder decodeObjectForKey:property] forKey:property];
        }
    }
    return self;
}

@end
