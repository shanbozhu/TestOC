//
//  PBRuntimeZeroDebugController+Debug.m
//  TestOC
//
//  Created by shanbo on 2024/4/22.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeZeroDebugController+Debug.h"
#import "PBRunTime.h"

@implementation PBRuntimeZeroDebugController (Debug)

// +load方法在main函数之前执行
+ (void)load {
    [PBRunTime replaceClass:NSClassFromString(@"PBRuntimeZeroController")
                        sel:NSSelectorFromString(@"run")
                  withClass:self
                    withSEL:NSSelectorFromString(@"debug_run") isClassMethod:YES];
}

+ (void)debug_run {
    NSLog(@"执行1. debug_run. 在分类中hook");
    NSLog(@"self = %@", self);
    [self debug_run];
}

@end
