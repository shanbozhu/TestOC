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
 交换两个类的类(类对象)方法
 
 @param cls 原类
 @param origSel 原类的类方法
 @param altCls 用于交换的类
 @param altSel 用于交换的类的类方法
 */
+ (BOOL)swizzleClassMethods:(Class)cls originalSEL:(SEL)origSel alternativeClass:(Class)altCls alternativeSEL:(SEL)altSel;

/**
 交换两个类的对象(实例)方法
 
 @param cls 原类
 @param origSel 原类的对象方法
 @param altCls 用于交换的类
 @param altSel 用于交换的类的对象方法
 */
+ (BOOL)swizzleInstanceMethods:(Class)cls originalSEL:(SEL)origSel alternativeClass:(Class)altCls alternativeSEL:(SEL)altSel;






/**
 * @brief MethodSwizzling 实例方法
 *
 * @param origCls hook的类
 * @param origSEL hook的方法
 * @param cls 替换的类
 * @param sel 替换的实例方法
 */
+ (void)replaceClass:(Class)origCls sel:(SEL)origSEL withClass:(Class)cls withSEL:(SEL)sel;

/**
 * @brief MethodSwizzling 方法
 *
 * @param origCls origCls hook的类
 * @param origSEL hook的方法
 * @param cls 替换的类
 * @param sel 替换的方法
 * @param isClassMethod YES 类方法 NO 实例方法
 */
+ (void)replaceClass:(Class)origCls sel:(SEL)origSEL withClass:(Class)cls withSEL:(SEL)sel isClassMethod:(BOOL)isClassMethod;

@end

NS_ASSUME_NONNULL_END
