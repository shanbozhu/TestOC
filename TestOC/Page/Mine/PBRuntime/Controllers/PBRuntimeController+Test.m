//
//  PBRuntimeController+Test.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/9/11.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeController+Test.h"
#import "PBMethodSwizzling.h"

/**
 hook:
 一般用于hook一个不可修改的原方法,而又需要在原方法的基础上添加代码.
 不同于单纯的category,因为单纯的category会覆盖原方法,在不需要原方法中的代码是可以的.如果我们需要原方法中的逻辑,然后在添加些自定义的逻辑,这种情况下就要使用hook了.
 */
@implementation PBRuntimeController (Test)

// +load方法在main函数之前执行
+ (void)load {
    [self doHook];
}

+ (void)doHook {
    SEL origSel1 = NSSelectorFromString(@"viewDidLoad");
    SEL altSel1 = NSSelectorFromString(@"pb_viewDidLoad");
    [PBMethodSwizzling swizzleInstanceMethods:self originalSEL:origSel1 alternativeClass:self alternativeSEL:altSel1];
    
    SEL origSel2 = NSSelectorFromString(@"func");
    SEL altSel2 = NSSelectorFromString(@"pb_func");
    [PBMethodSwizzling swizzleClassMethods:self originalSEL:origSel2 alternativeClass:self alternativeSEL:altSel2];
}

- (void)pb_viewDidLoad {
    NSLog(@"[对象方法]被执行了1.先执行自定义语句,在执行下面的原方法");
    [self pb_viewDidLoad]; // 交换了方法,实际调用的是[self viewDidLoad];
}

+ (void)pb_func {
    NSLog(@"[类方法]被执行了1.先执行自定义语句,在执行下面的原方法");
    [self pb_func]; // 交换了方法,实际调用的是[self func];
}

@end
