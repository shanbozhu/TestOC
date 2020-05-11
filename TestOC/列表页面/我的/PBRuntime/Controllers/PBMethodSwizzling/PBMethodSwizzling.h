//
//  PBMethodSwizzling.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/9/11.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBMethodSwizzling : NSObject

/**
 交换两个类的对象(实例)方法
 @param cls 原类
 @param origSel 原类的对象方法
 @param altCls 用于交换的类
 @param altSel 用于交换的类的对象方法
 */
+ (BOOL)swizzleClassMethods:(Class)cls originalSEL:(SEL)origSel alternativeClass:(Class)altCls alternativeSEL:(SEL)altSel;

/**
 交换两个类的类方法
 @param cls 原类
 @param origSel 原类的类方法
 @param altCls 用于交换的类
 @param altSel 用于交换的类的类方法
 */
+ (BOOL)swizzleInstanceMethods:(Class)cls originalSEL:(SEL)origSel alternativeClass:(Class)altCls alternativeSEL:(SEL)altSel;

@end

NS_ASSUME_NONNULL_END
