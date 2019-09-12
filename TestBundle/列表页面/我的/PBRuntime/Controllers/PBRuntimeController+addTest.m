//
//  PBRuntimeController+addTest.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/9/11.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeController+addTest.h"
#import "PBMethodSwizzling.h"

@implementation PBRuntimeController (addTest)

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
