//
//  PBMethodSwizzling.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/9/11.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBMethodSwizzling.h"
#import <objc/runtime.h>

@interface PBMethodSwizzling ()

@end

@implementation PBMethodSwizzling

+ (BOOL)swizzleClassMethods:(Class)cls originalSEL:(SEL)origSel alternativeClass:(Class)altCls alternativeSEL:(SEL)altSel {
    Method originMethod = class_getClassMethod(cls, origSel);
    if (!originMethod) {
        return NO;
    }
    Method newMethod = class_getClassMethod(altCls, altSel);
    if (!newMethod) {
        return NO;
    }
    if (class_addMethod(objc_getMetaClass(class_getName(cls)), origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(objc_getMetaClass(class_getName(cls)), altSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, newMethod);
    }
    return YES;
}

+ (BOOL)swizzleInstanceMethods:(Class)cls originalSEL:(SEL)origSel alternativeClass:(Class)altCls alternativeSEL:(SEL)altSel {
    Method originMethod = class_getInstanceMethod(cls, origSel);
    if (!originMethod) {
        return NO;
    }
    Method newMethod = class_getInstanceMethod(altCls, altSel);
    if (!newMethod) {
        return NO;
    }
    if (class_addMethod(cls, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(cls, altSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, newMethod);
    }
    return YES;
}

@end
