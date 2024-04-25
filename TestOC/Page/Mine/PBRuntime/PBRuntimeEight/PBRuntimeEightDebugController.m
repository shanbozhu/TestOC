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

+ (void)load {
    Class cls = NSClassFromString(@"PBRuntimeEightController");
    [self.class addPropertyWithtarget:cls withPropertyName:@"height"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

static NSMutableDictionary *dictCustomerProperty;


+ (void)addPropertyWithtarget:(Class)cls withPropertyName:(NSString *)propertyName {
    // 先判断有没有这个属性，没有就添加，有就返回
    Ivar ivar = class_getInstanceVariable(cls, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return;
    }
    
    objc_property_attribute_t attrs[] = {  };
    if (class_addProperty(cls, [propertyName UTF8String], attrs, 0)) {
        class_addMethod(cls, NSSelectorFromString(propertyName), (IMP)customGetter, "@@:");
        class_addMethod(cls, NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)customSetter, "v@:@");
    } else {
        class_replaceProperty(cls, [propertyName UTF8String], attrs, 0);
        //添加get和set方法
        class_addMethod(cls, NSSelectorFromString(propertyName), (IMP)customGetter, "@@:");
        class_addMethod(cls, NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)customSetter, "v@:@");
    }
}

id customGetter(id self, SEL _cmd) {
    if (dictCustomerProperty == nil) {
        dictCustomerProperty = [NSMutableDictionary new];
    }
    NSString *key = NSStringFromSelector(_cmd);
    return [dictCustomerProperty objectForKey:key];
}

void customSetter(id self, SEL _cmd, id newValue) {
    //移除set
    NSString *key = [NSStringFromSelector(_cmd) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    //首字母小写
    NSString *head = [key substringWithRange:NSMakeRange(0, 1)];
    head = [head lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
    //移除后缀 ":"
    key = [key stringByReplacingCharactersInRange:NSMakeRange(key.length - 1, 1) withString:@""];
    
    if (dictCustomerProperty == nil) {
        dictCustomerProperty = [NSMutableDictionary new];
    }
    
    [dictCustomerProperty setObject:newValue forKey:key];
}

@end
