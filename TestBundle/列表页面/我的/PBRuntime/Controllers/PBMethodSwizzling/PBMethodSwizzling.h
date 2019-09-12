//
//  PBMethodSwizzling.h
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/9/11.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBMethodSwizzling : NSObject

+ (BOOL)swizzleClassMethods:(Class)cls originalSEL:(SEL)origSel alternativeClass:(Class)altCls alternativeSEL:(SEL)altSel;
+ (BOOL)swizzleInstanceMethods:(Class)cls originalSEL:(SEL)origSel alternativeClass:(Class)altCls alternativeSEL:(SEL)altSel;

@end

NS_ASSUME_NONNULL_END
