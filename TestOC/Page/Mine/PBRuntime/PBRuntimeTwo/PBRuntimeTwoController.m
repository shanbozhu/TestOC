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

- (void)ivarList:(id)object {
    unsigned int count = 0;
    Ivar *ivar = class_copyIvarList([object class], &count);
    for (NSInteger index = 0; index < count; index++) {
        const char *ivarName = ivar_getName(ivar[index]);
        NSString *name = [NSString stringWithUTF8String:ivarName];
        NSLog(@"成员变量: %@, 值: %@", name, [object valueForKey:name]);
    }
    free(ivar);
}

- (void)propertyList:(id)object {
    unsigned int count = 0;
    objc_property_t *propertiesList = class_copyPropertyList([object class], &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertiesList[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        NSLog(@"属性: %@, 值: %@", name, [object valueForKey:name]);
    }
    free(propertiesList);
}


#pragma mark -

+ (void)manager {
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        [self ivarList:self];
    }
    
    {
        [self propertyList:self];
    }
    
    {
        unsigned int count = 0;
        Method *method = class_copyMethodList([self class], &count);
        for (unsigned int i = 0; i < count; i++) {
            Method me = method[i];
            NSLog(@"方法名称----%@", NSStringFromSelector(method_getName(me)));
        }
        free(method);
    }
    
    {
        unsigned int count = 0;
        Class metaClass = object_getClass([self class]);
        Method *method = class_copyMethodList(metaClass, &count);
        for (unsigned int i = 0; i < count; i++) {
            Method me = method[i];
            NSLog(@"类方法名称----%@", NSStringFromSelector(method_getName(me)));
        }
        free(method);
    }
    
    {
        Protocol *protocol = @protocol(PBRuntimeTwoControllerProtocol);
        unsigned int count = 0;
        struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, YES, YES, &count); // 第二个参数是否是required,第三个参数是否是对象方法
        for (unsigned int i = 0; i < count; i++) {
            struct objc_method_description method = methods[i];
            NSLog(@"协议方法名称----%@", NSStringFromSelector(method.name));
        }
        free(methods);
    }
    
    {
        unsigned int count = 0;
        __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
        for (unsigned int i = 0; i< count; i++) {
            Protocol *myProtocal = protocolList[i];
            const char *protocolName = protocol_getName(myProtocal);
            NSLog(@"协议名称----%@", [NSString stringWithUTF8String:protocolName]);
        }
        free(protocolList);
    }
}

@end
