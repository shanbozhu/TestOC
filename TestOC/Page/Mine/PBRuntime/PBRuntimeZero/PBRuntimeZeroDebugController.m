//
//  PBRuntimeZeroDebugController.m
//  TestOC
//
//  Created by shanbo on 2024/4/15.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeZeroDebugController.h"
#import "PBRunTime.h"

/**
 hook：
 一般用于hook一个不可修改的原方法，而又需要在原方法的基础上添加代码
 */

@interface PBRuntimeZeroDebugController ()

@end

@implementation PBRuntimeZeroDebugController

#pragma mark -

// +load方法在main函数之前执行
+ (void)load {
    [PBRunTime replaceClass:NSClassFromString(@"PBRuntimeZeroController")
                        sel:NSSelectorFromString(@"func")
                  withClass:self
                    withSEL:NSSelectorFromString(@"debug_func")
              isClassMethod:YES];
}

+ (void)debug_func {
    NSLog(@"执行1. debug_func. 在任意类中hook");
    NSLog(@"使用hook时，PBRuntimeZeroDebugController可以没有任何调用");
    NSLog(@"self = %@", self); // hook方法中要慎用self，防止self指代错误
    [self debug_func]; // 交换了方法，此时self是PBRuntimeZeroController，debug_func是func
}

@end
