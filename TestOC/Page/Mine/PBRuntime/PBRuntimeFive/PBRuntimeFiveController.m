//
//  PBRuntimeFiveController.m
//  TestOC
//
//  Created by shanbo on 2024/4/19.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeFiveController.h"
#import <objc/runtime.h>
#import "PBRuntimeFiveDebugController.h"

@interface PBRuntimeFiveController ()

@end

@implementation PBRuntimeFiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test];
}

- (void)run {
    NSLog(@"----run-----");
}

//// 方案一
//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(test)) {
//        IMP imp = class_getMethodImplementation(self, @selector(run));
//        class_addMethod(self, sel, imp, "v@:");
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}
//
//// 方案二
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    if (aSelector == @selector(test)) {
//        return [PBRuntimeFiveDebugController new];
//    }
//    return nil;
//}

// 方案三
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(test)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = [anInvocation selector];
    PBRuntimeFiveDebugController *forward = [PBRuntimeFiveDebugController new];
    if ([forward respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:forward];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

@end
