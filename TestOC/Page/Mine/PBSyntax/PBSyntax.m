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
 interface 类声明
 implementation 类定义
 protocol 协议：公用方法声明。遵守协议，含有方法声明。
 category 分类：方法定义
 @property 声明私有成员变量，定义getter、setter方法
 
 @synthesize 声明私有成员变量
 @dynamic 必须手动声明私有成员变量，必须手动定义getter、setter方法
 */

// class property
static NSString *_someString;
static Class<PBSyntaxProtocol> _someCls;

#pragma mark - implementation

@implementation PBSyntax

@synthesize name=_name;
@dynamic height;
@dynamic someString;
@dynamic someCls;

- (instancetype)init {
    if (self = [super init]) {
        self.height = @"180";
    }
    return self;
}

#pragma mark - 有@synthesize修饰，可以同时重写getter、setter方法

- (NSString *)name {
    return _name;
}

- (void)setName:(NSString *)name {
    // self是方法的默认参数
    // 等价于 self->_name = name;
    _name = name;
}

#pragma mark - 没有@synthesize修饰，只能同时重写getter、setter方法中的一种

//- (NSString *)age {
//    return _age; // 若同时重写，会导致未声明成员变量
//}

- (void)setAge:(NSString *)age {
    _age = age;
}

#pragma mark - 有@dynamic修饰，必须同时重写getter、setter方法

- (NSString *)height {
    return _height;
}

- (void)setHeight:(NSString *)height {
    _height = height;
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
    // 设置self的关联对象key/value
    objc_setAssociatedObject(self, @selector(sing), sing, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sing {
    // 获取self的关联对象key/value
    return objc_getAssociatedObject(self, @selector(sing));
}

#pragma mark - class property

+ (void)setSomeString:(NSString *)someString {
    _someString = someString;
}

+ (NSString *)someString {
    return _someString;
}

+ (void)setSomeCls:(Class<PBSyntaxProtocol>)someCls {
    _someCls = someCls;
}

+ (Class<PBSyntaxProtocol>)someCls {
    return _someCls;
}

@end
