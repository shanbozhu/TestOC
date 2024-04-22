//
//  PBRuntimeZeroDebugController+Debug.m
//  TestOC
//
//  Created by shanbo on 2024/4/22.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeZeroDebugController+Debug.h"
#import "PBMethodSwizzling.h"

@implementation PBRuntimeZeroDebugController (Debug)

// +load方法在main函数之前执行
+ (void)load {
    [PBMethodSwizzling replaceClass:NSClassFromString(@"PBRuntimeZeroController")
                                sel:NSSelectorFromString(@"run")
                          withClass:self
                            withSEL:NSSelectorFromString(@"debug_run") isClassMethod:YES];
}

+ (void)debug_run {
    NSLog(@"debug_run被执行了1.先执行自定义语句,在执行下面的原方法");
    NSLog(@"self = %@", self);
    [self debug_run];
}

@end
