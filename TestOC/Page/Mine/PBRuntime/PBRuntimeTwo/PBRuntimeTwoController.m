//
//  PBRuntimeTwoController.m
//  TestOC
//
//  Created by shanbo on 2023/3/20.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeTwoController.h"
#import <objc/runtime.h>

/**
 参考文档:
 iOS获取某类的属性/方法/成员变量/协议列表 https://www.jianshu.com/p/c2cf4a9cee74
 iOS获取协议中的全部方法 https://www.jianshu.com/p/ebde55ddc094
 */

@interface PBRuntimeTwoController ()

@end

@implementation PBRuntimeTwoController

#pragma mark -

+ (void)ivarList:(id)object {
    unsigned int count = 0;
    Ivar *ivar = class_copyIvarList([object class], &count);
    for (NSInteger index = 0; index < count; index++) {
        const char *ivarName = ivar_getName(ivar[index]);
        NSString *name = [NSString stringWithUTF8String:ivarName];
        NSLog(@"成员变量: %@, 值: %@", name, [object valueForKey:name]);
    }
    free(ivar);
}

+ (void)propertyList:(id)object {
    unsigned int count = 0;
    objc_property_t *propertiesList = class_copyPropertyList([object class], &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertiesList[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        NSLog(@"属性: %@, 值: %@", name, [object valueForKey:name]);
    }
    free(propertiesList);
}

+ (void)instanceMethodList:(id)object {
    unsigned int count = 0;
    Method *method = class_copyMethodList([object class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Method me = method[i];
        NSLog(@"方法: %@", NSStringFromSelector(method_getName(me)));
    }
    free(method);
}

+ (void)classMethodList:(id)object {
    unsigned int count = 0;
    Class metaClass = object_getClass([self class]);
    Method *method = class_copyMethodList(metaClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method me = method[i];
        NSLog(@"类方法: %@", NSStringFromSelector(method_getName(me)));
    }
    free(method);
}

+ (void)protocolMethodList:(Protocol *)protocol {
    unsigned int count = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, YES, YES, &count); // 第二个参数是否是required,第三个参数是否是对象方法
    for (unsigned int i = 0; i < count; i++) {
        struct objc_method_description method = methods[i];
        NSLog(@"协议方法: %@", NSStringFromSelector(method.name));
    }
    free(methods);
}

+ (void)conformProtocolList:(id)object {
    unsigned int count = 0;
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([object class], &count);
    for (unsigned int i = 0; i< count; i++) {
        Protocol *myProtocal = protocolList[i];
        const char *protocolName = protocol_getName(myProtocal);
        NSLog(@"协议: %@", [NSString stringWithUTF8String:protocolName]);
    }
    free(protocolList);
}

#pragma mark -

+ (void)manager {
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        // 成员变量
        [self.class ivarList:self];
    }
    
    {
        // 属性
        [self.class propertyList:self];
    }
    
    {
        // 方法
        [self.class instanceMethodList:self];
    }
    
    {
        // 类方法
        [self.class classMethodList:self];
    }
    
    {
        // 协议方法
        [self.class protocolMethodList:@protocol(PBRuntimeTwoControllerProtocol)];
    }
    
    {
        // 协议
        [self.class conformProtocolList:self];
    }
}

@end
