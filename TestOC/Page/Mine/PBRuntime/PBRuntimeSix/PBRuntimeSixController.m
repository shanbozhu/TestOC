//
//  PBRuntimeSixController.m
//  TestOC
//
//  Created by shanbo on 2024/4/22.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeSixController.h"

@interface PBRuntimeSixController ()

@end

@implementation PBRuntimeSixController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    {
        /**
         3.NSInvocation调用方法
         3.1进行方法签名；NSMethodSignature的两个参数：numberOfArguments方法参数的个数；methodReturnLength方法返回值类型
         的长度，大于0表示有返回值
         3.2初始化NSInvocation并设置参数
         第一个参数下标为0是target，及响应者；
         第二个参数是selector，及需要调用的方法；
         第三个起是自定义参数，必须传递参数的地址，不能直接传值，例如：str1，str2，str3
         3.3获取返回值；可以在调用invoke前，也可以在invoke之后
         */
        SEL selector = @selector(runA:b:c:);
        NSMethodSignature *sign = [self methodSignatureForSelector:selector];
        //NSMethodSignature *sign = [self.class instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
        invocation.target = self;
        invocation.selector = selector;
        NSString *arg1 = @"a";
        NSString *arg2 = @"b";
        NSString *arg3 = @"c";
        [invocation setArgument:&arg1 atIndex:2];
        [invocation setArgument:&arg2 atIndex:3];
        [invocation setArgument:&arg3 atIndex:4];
        [invocation invoke];
        if (sign.methodReturnLength > 0) {
            NSString *result = nil;
            [invocation getReturnValue:&result];
            NSLog(@"result = %@", result);
        } else {
            NSLog(@"没有返回值");
        }
    }
}

- (NSString *)runA:(NSString *)a b:(NSString *)b c:(NSString *)c {
    NSLog(@"----run-----, a: %@, b: %@, c: %@", a, b, c);
    return @"NSInvocation Succeed!";
}

@end
