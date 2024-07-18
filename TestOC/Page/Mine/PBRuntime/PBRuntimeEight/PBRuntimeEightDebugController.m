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
    [self.class addPropertyWithClass:cls propertyName:@"height" propertyType:NSString.class];
}

+ (void)addPropertyWithClass:(Class)cls propertyName:(NSString *)propertyName propertyType:(Class)propertyTypeCls {
    // 先判断有没有这个属性，没有就添加，有就返回
    Ivar ivar = class_getInstanceVariable(cls, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return;
    }
    
    // 写法一
//    unsigned int count = 4;
//    objc_property_attribute_t attrs[count]; // 属性的属性
//    // 添加类型
//    objc_property_attribute_t t1;
//    t1.name = "T";
//    t1.value = [[NSString stringWithFormat:@"@\"%@\"", NSStringFromClass(propertyTypeCls)] UTF8String];
//    // 添加copy
//    objc_property_attribute_t t2;
//    t2.name = "C"; // copy修饰传"C"，strong修饰传"&"，assign修饰不传
//    t2.value = "";
//    // 添加nonatomic
//    objc_property_attribute_t t3;
//    t3.name = "N";
//    t3.value = "";
//    // 添加ivar
//    objc_property_attribute_t t4;
//    t4.name = "V";
//    t4.value = [[NSString stringWithFormat:@"_%@", propertyName] UTF8String];
//    attrs[0] = t1;
//    attrs[1] = t2;
//    attrs[2] = t3;
//    attrs[3] = t4;
    
    // 写法二
//    objc_property_attribute_t t1 = { "T", "@\"NSString\"" };
//    objc_property_attribute_t t2 = { "C", "" };
//    objc_property_attribute_t t3 = { "N", "" };
//    objc_property_attribute_t t4  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
//    objc_property_attribute_t attrs[] = { t1, t2, t3, t4 }; // 结构体数组:数组里面每个元素是结构体.attrs(数组名)存储(指向)数组首元素地址
    
    // 写法三
    objc_property_attribute_t *attrs = malloc(4 * sizeof(objc_property_attribute_t));
    objc_property_attribute_t t1 = { "T", "@\"NSString\"" };
    objc_property_attribute_t t2 = { "C", "" };
    objc_property_attribute_t t3 = { "N", "" };
    objc_property_attribute_t t4  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
    attrs[0] = t1;
    attrs[1] = t2;
    attrs[2] = t3;
    attrs[3] = t4;
    
    if (class_addProperty(cls, [propertyName UTF8String], attrs, 4)) {
        class_addMethod(cls, NSSelectorFromString(propertyName), (IMP)getter, "@@:");
        class_addMethod(cls, NSSelectorFromString([NSString stringWithFormat:@"set%@:", [self dealPropertyName:propertyName]]), (IMP)setter, "v@:@");
    } else {
        class_replaceProperty(cls, [propertyName UTF8String], attrs, 4);
        class_addMethod(cls, NSSelectorFromString(propertyName), (IMP)getter, "@@:");
        class_addMethod(cls, NSSelectorFromString([NSString stringWithFormat:@"set%@:", [self dealPropertyName:propertyName]]), (IMP)setter, "v@:@");
    }
    // 写法三
    free(attrs);
}

+ (NSString *)dealPropertyName:(NSString *)dealString {
    NSString *resultString = @"";
    if (dealString.length > 0) {
        resultString = [dealString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[dealString substringToIndex:1] capitalizedString]];
    }
    return resultString;
}

id getter(id self, SEL _cmd) {
    NSString *key = NSStringFromSelector(_cmd);
    return objc_getAssociatedObject(self, NSSelectorFromString(key));
}

void setter(id self, SEL _cmd, id newValue) {
    if (!newValue) {
        return;
    }
    // 移除set
    NSString *key = [NSStringFromSelector(_cmd) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    // 首字母小写
    NSString *head = [key substringWithRange:NSMakeRange(0, 1)];
    head = [head lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
    // 移除后缀 ":"
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
