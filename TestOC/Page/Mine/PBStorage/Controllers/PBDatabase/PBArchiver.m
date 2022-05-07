//
//  PBArchiver.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/17.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBArchiver.h"
#import "NSObject+PBRuntime.h"

#pragma mark - [归解档]例子

/**
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.hasRequestedAsyncAd forKey:@"hasRequestedAsyncAd"];
    if (self.floor) {
        [aCoder encodeObject:self.floor forKey:@"floor"];
    }
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.hasRequestedAsyncAd = [aDecoder decodeBoolForKey:@"hasRequestedAsyncAd"];
        self.floor = [aDecoder decodeObjectForKey:@"floor"];
    }
    return self;
}
 */

@implementation PBArchiver

#pragma mark - 支持[归解挡]操作的[模型对象]需要实现的方法

// 归档时当前对象需要实现的代理方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *property in [self pb_propertyList]) {
        [aCoder encodeObject:[self valueForKey:property] forKey:property];
    }
}

// 解档时当前对象需要实现的代理方法
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        for (NSString *property in [self pb_propertyList]) {
            [self setValue:[aDecoder decodeObjectForKey:property] forKey:property];
        }
    }
    return self;
}

#pragma mark - [归解档]操作

+ (NSData *)dataWithObject:(id)obj key:(NSString *)key {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:obj forKey:key];
    [archiver finishEncoding];
    return data;
}

+ (id)objectWithData:(NSData *)data key:(NSString *)key {
    if (!data || data.length == 0) {
        return nil;
    }
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    id obj = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    return obj;
}

+ (NSData *)dataWithObjects:(NSArray *)objs keys:(NSArray *)keys {
    if (keys.count != objs.count) {
        return nil;
    }
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    for (int i = 0; i < keys.count; i++) {
        [archiver encodeObject:objs[i] forKey:keys[i]];
    }
    [archiver finishEncoding];
    return data;
}

+ (NSArray *)objectsWithData:(NSData *)data keys:(NSArray *)keys {
    if (!data || data.length == 0) {
        return nil;
    }
    NSMutableArray *objs = [NSMutableArray array];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    for (int i = 0; i < keys.count; i++) {
        id obj = [unarchiver decodeObjectForKey:keys[i]];
        [objs addObject:obj];
    }
    [unarchiver finishDecoding];
    return objs;
}

@end
