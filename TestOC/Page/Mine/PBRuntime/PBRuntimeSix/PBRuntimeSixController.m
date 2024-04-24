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
        // 方案一
        [self run];
    }
    
    {
        // 方案二
        
        // 执行对象方法
        [self performSelector:@selector(run) withObject:nil];
        
        // 执行类方法
        [PBRuntimeSixController performSelector:@selector(func:) withObject:@"func"];
        [self.class performSelector:@selector(func:) withObject:@"func"];
    }
    
    {
        // 方案三
        /**
         NSInvocation调用方法
         1.进行方法签名；NSMethodSignature的两个参数：
            numberOfArguments 方法参数的个数
            methodReturnLength 方法返回值类型的长度，大于0表示有返回值
         2.初始化NSInvocation并设置参数
            第一个参数下标为0是target，即响应者；
            第二个参数是selector，即需要调用的方法；
            第三个起是自定义参数，必须传递参数的地址，不能直接传值，例如：str1，str2，str3
         3.获取返回值；可以在调用invoke前，也可以在invoke之后
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
        NSLog(@"执行2. sign.numberOfArguments = %ld, sign.methodReturnLength = %ld", sign.numberOfArguments, sign.methodReturnLength);
        if (sign.methodReturnLength > 0) {
            NSString *result = nil;
            [invocation getReturnValue:&result];
            NSLog(@"执行3. result = %@", result);
        } else {
            NSLog(@"没有返回值");
        }
    }
    
    {
        // 方案四
        
        // 强制转换和调用分开
        void *(*msgSend)(id, SEL, NSString *, NSString *, NSString *) = (void *)objc_msgSend;
        NSString *r = (__bridge NSString *)(msgSend(self, @selector(runA:b:c:), @"a", @"b", @"c"));
        NSLog(@"%@", r);
        
        // 强制转换和调用一起
        NSString *r2 = ((NSString *(*)(id, SEL, NSString *, NSString *, NSString *))objc_msgSend)(self, @selector(runA:b:c:), @"a", @"b", @"c");
        NSLog(@"%@", r2);
    }
}

- (NSString *)runA:(NSString *)a b:(NSString *)b c:(NSString *)c {
    NSLog(@"执行1. ----invoke----, a = %@, b = %@, c = %@", a, b, c);
    return @"NSInvocation Succeed!";
}

- (void)run {
    NSLog(@"----run----");
}

- (void)func:(NSString *)name {
    NSLog(@"----func----, name = %@", name);
}

+ (void)func:(NSString *)name {
    NSLog(@"----func----, name = %@", name);
}

@end
