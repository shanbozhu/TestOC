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

// 参考文档:
// iOS - 动态添加方法和消息转发 https://blog.csdn.net/u013712343/article/details/108060035

@interface PBRuntimeFiveController ()

- (void)test:(NSString *)name;

@end

@implementation PBRuntimeFiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test:@"test"];
}

- (void)run {
    NSLog(@"----run----");
}

#pragma mark - 方案一

//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(test)) {
//        IMP imp = class_getMethodImplementation(self, @selector(run));
//        class_addMethod(self, sel, imp, "v@:");
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}

#pragma mark - 方案二

//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    if (aSelector == @selector(test)) {
//        return [PBRuntimeFiveDebugController new];
//    }
//    return nil;
//}

#pragma mark - 方案三

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(test:)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:#"];
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
