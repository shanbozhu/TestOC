//
//  PBSyntax.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/12.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBSyntax.h"
#import <objc/runtime.h>

/**
 interface类声明
 implementation类定义
 protocol协议方法声明.遵循协议,实现协议方法的定义
 category分类方法定义
 @property声明私有成员变量,定义getter、setter方法
 @synthesize声明私有成员变量
 @dynamic必须手动声明私有成员变量,定义getter、setter方法
 */

#pragma mark - implementation
@implementation PBSyntax

@synthesize name=_name;
@dynamic height;

- (instancetype)init {
    if (self = [super init]) {
        self.height = @"180";
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

//- (NSString *)age {
//    return _age;
//}

#pragma mark - 有@dynamic修饰,必须同时重写getter、setter方法,私有成员变量如果需要使用也要自己声明
- (void)setHeight:(NSString *)height {
    _height = height;
}

- (NSString *)height {
    return _height;
}

#pragma mark - protocol
- (NSString *)sex {
    return @"male";
}

#pragma mark - extension
- (NSString *)hobby {
    return @"dance";
}

@end

#pragma mark - category
@implementation PBSyntax (ability)

- (void)setSing:(NSString *)sing {
    // 全局存储
    // 设置self的关联对象key/value
    objc_setAssociatedObject(self, @selector(sing), sing, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sing {
    // 获取self的关联对象key/value
    return objc_getAssociatedObject(self, @selector(sing));
}

@end
