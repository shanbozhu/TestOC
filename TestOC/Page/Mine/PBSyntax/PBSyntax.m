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
 1. interface 接口：类的声明。有声明，就能调用，就能被编译器识别。
 2. implementation 实现：类的定义。
 3. protocol 协议：只含有方法声明的公共头文件。
 3.1 表现形式：id<protocol>、Class<protocol>、UIView<protocol> *
 3.2 <protocol>：遵守协议，含有方法声明。
 4. category 分类：方法定义
 
 1. @property 声明私有成员变量，定义getter、setter方法
 2. @synthesize 声明私有成员变量
 */

// class property
static NSString *_someString;
static Class<PBSyntaxProtocol> _someCls;

@implementation PBSyntax

@synthesize name=_name;
//@synthesize height = _height; // 既可以在接口（interface）里声明私有成员变量，也可以在实现（implementation）里通过@synthesize声明私有成员变量

#pragma mark - init

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - interface

// 没有@synthesize修饰，只能同时重写getter、setter方法中的一种。若同时重写，需要手动声明私有成员变量。

// property

//- (NSString *)age {
//    return _age; // 同时重写会报错：提示未声明成员变量
//}

- (void)setAge:(NSString *)age {
    // self是方法的默认参数
    // 等价于 self->_age = age;
    _age = age;
}

- (NSString *)height {
    return _height;
}

- (void)setHeight:(NSString *)height {
    _height = height;
}

// class property

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
//@dynamic sing; // 使用@dynamic只会去除警告，实际上并不会自动生成getter、setter方法，执行会崩溃。

- (void)setSing:(NSString *)sing {
    // 设置 self的关联对象key/value
    objc_setAssociatedObject(self, @selector(sing), sing, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sing {
    // 获取 self的关联对象key/value
    return objc_getAssociatedObject(self, @selector(sing));
}

@end
