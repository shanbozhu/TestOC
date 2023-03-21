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

+ (void)manager {
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        unsigned int ivarCount;
        Ivar *ivar = class_copyIvarList([self class], &ivarCount);
        for (NSInteger index = 0; index < ivarCount; index++) {
            const char *ivarName = ivar_getName(ivar[index]);
            NSLog(@"成员变量名称----%@", [NSString stringWithUTF8String:ivarName]);
        }
        free(ivar);
    }
    
    {
        unsigned int number;
        objc_property_t *propertiList = class_copyPropertyList([self class], &number);
        for (unsigned int i = 0; i < number; i++) {
            const char *propertyName = property_getName(propertiList[i]);
            NSLog(@"属性名称----%@", [NSString stringWithUTF8String:propertyName]);
        }
        free(propertiList);
    }
    
    {
        unsigned int methodCount;
        Method *method = class_copyMethodList([self class], &methodCount);
        for (unsigned int i = 0; i < methodCount; i++) {
            Method me = method[i];
            NSLog(@"方法名称----%@", NSStringFromSelector(method_getName(me)));
        }
        free(method);
    }
    
    {
        unsigned int methodCount;
        Class metaClass = object_getClass([self class]);
        Method *method = class_copyMethodList(metaClass, &methodCount);
        for (unsigned int i = 0; i < methodCount; i++) {
            Method me = method[i];
            NSLog(@"类方法名称----%@", NSStringFromSelector(method_getName(me)));
        }
        free(method);
    }
    
    {
        Protocol *protocol = @protocol(PBRuntimeTwoControllerProtocol);
        unsigned int count = 0;
        struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, YES, YES, &count);
        for (unsigned int i = 0; i < count; i++) {
            struct objc_method_description method = methods[i];
            NSLog(@"协议方法名称----%@", NSStringFromSelector(method.name));
        }
        free(methods);
    }
    
    {
        unsigned int protocalCount;
        __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &protocalCount);
        for (unsigned int i = 0; i< protocalCount; i++) {
            Protocol *myProtocal = protocolList[i];
            const char *protocolName = protocol_getName(myProtocal);
            NSLog(@"协议名称----%@", [NSString stringWithUTF8String:protocolName]);
        }
        free(protocolList);
    }
}


@end
