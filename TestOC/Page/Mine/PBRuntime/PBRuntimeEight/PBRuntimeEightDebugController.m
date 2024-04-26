//
//  PBRuntimeEightDebugController.m
//  TestOC
//
//  Created by shanbo on 2024/4/25.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeEightDebugController.h"

@interface PBRuntimeEightDebugController ()

@end

@implementation PBRuntimeEightDebugController

#pragma mark -

+ (void)load {
    Class cls = NSClassFromString(@"PBRuntimeEightController");
    [self.class addPropertyWithClass:cls propertyName:@"height"];
}

+ (void)addPropertyWithClass:(Class)cls propertyName:(NSString *)propertyName {
    // 先判断有没有这个属性，没有就添加，有就返回
    Ivar ivar = class_getInstanceVariable(cls, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return;
    }
    
    unsigned int count = 4;
    objc_property_attribute_t attrs[count];
    // 添加类型
    objc_property_attribute_t t1;
    t1.name = "T";
    t1.value = "NSString";
    // 添加ivar
    objc_property_attribute_t t2;
    t2.name = "V";
    t2.value = [[NSString stringWithFormat:@"_%@", propertyName] UTF8String];
    // 添加nonatomic
    objc_property_attribute_t t3;
    t3.name = "N";
    t3.value = "";
    // 添加copy
    objc_property_attribute_t t4;
    t4.name = "C";
    t4.value = "";
    
    attrs[0] = t1;
    attrs[1] = t2;
    attrs[2] = t3;
    attrs[3] = t4;
    
    if (class_addProperty(cls, [propertyName UTF8String], attrs, count)) {
        class_addMethod(cls, NSSelectorFromString(propertyName), (IMP)customGetter, "@@:");
        class_addMethod(cls, NSSelectorFromString([NSString stringWithFormat:@"set%@:", [self dealPropertyName:propertyName]]), (IMP)customSetter, "v@:@");
    } else {
        class_replaceProperty(cls, [propertyName UTF8String], attrs, 0);
        class_addMethod(cls, NSSelectorFromString(propertyName), (IMP)customGetter, "@@:");
        class_addMethod(cls, NSSelectorFromString([NSString stringWithFormat:@"set%@:", [self dealPropertyName:propertyName]]), (IMP)customSetter, "v@:@");
    }
}

+ (NSString *)dealPropertyName:(NSString *)dealString {
    NSString *resultString = @"";
    if (dealString.length > 0) {
        resultString = [dealString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[dealString substringToIndex:1] capitalizedString]];
    }
    return resultString;
}

id customGetter(id self, SEL _cmd) {
    NSString *key = NSStringFromSelector(_cmd);
    return objc_getAssociatedObject(self, NSSelectorFromString(key));
}

void customSetter(id self, SEL _cmd, id newValue) {
    if (!newValue) {
        return;
    }
    //移除set
    NSString *key = [NSStringFromSelector(_cmd) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    //首字母小写
    NSString *head = [key substringWithRange:NSMakeRange(0, 1)];
    head = [head lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
    //移除后缀 ":"
    key = [key stringByReplacingCharactersInRange:NSMakeRange(key.length - 1, 1) withString:@""];
    objc_setAssociatedObject(self, NSSelectorFromString(key), newValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 (lldb) po key
 strategyDetail
 (lldb) po _cmd
 "setStrategyDetail:"
 (lldb) po @selector(key)
 "key"
 (lldb) po NSSelectorFromString(key)
 "strategyDetail"

 Printing description of self:
 <BBANovelSecondBarBookModel: 0x133e14bd0>


 (lldb) po key
 strategyDetail
 (lldb) po _cmd
 "strategyDetail"
 (lldb) po @selector(key)
 "key"
 (lldb) po NSSelectorFromString(key)
 "strategyDetail"

 Printing description of self:
 <BBANovelSecondBarBookModel: 0x133e14bd0>
 */

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
