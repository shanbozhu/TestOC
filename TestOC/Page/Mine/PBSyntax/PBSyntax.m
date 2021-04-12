//
//  PBSyntax.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/12.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBSyntax.h"

/**
 protocol协议方法声明
 category分类方法定义
 @property声明私有成员变量,定义getter、setter方法
 @synthesize声明私有成员变量
 @dynamic使用子类成员变量
 */


@implementation PBSyntax
@synthesize name=_name;
@dynamic height;

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - 有@synthesize修饰,可以同时重写setter、getter方法
- (void)setName:(NSString *)name {
    _name = name;
}

- (NSString *)name {
    return _name;
}

#pragma mark - 没有@synthesize修饰,只能同时重写setter、getter中的一种方法
- (void)setAge:(NSString *)age {
    _age = age;
}

/**
- (NSString *)age {
    return _age;
}
 */

#pragma mark - 遵循协议,实现协议方法的定义
- (NSString *)sex {
    return @"Male";
}


@end
