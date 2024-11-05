//
//  PBExceptionController.m
//  TestOC
//
//  Created by zhushanbo on 2024/11/5.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBExceptionController.h"

// iOS开发-捕获异常,抛出异常 https://blog.csdn.net/qq_48946910/article/details/112480343

/**
 在iOS开发中，异常（Exceptions）和断言（Assertions）是两种不同的错误处理机制。
 
 异常通常用于处理预期之外的错误情况，而断言主要用于开发阶段调试，以确保程序运行时满足特定条件。
 
 当iOS遇到异常时，程序会生成一个异常栈信息，并开始搜索异常处理代码（通常是@catch块）。如果没有找到处理代码，程序会终止，并弹出异常信息。
 
 断言是开发者在代码中插入的条件语句，用于检查程序是否满足某些预期的条件。如果条件不满足，则会触发一个断言失败，通常会终止程序。
 */

/**
 在实际开发中，选择使用异常还是断言，通常取决于错误的严重程度以及你是否希望在生产环境中继续运行程序。对于那些可以安全恢复或者有明确错误处理策略的严重错误，使用异常可能更为合适；而对于开发阶段的bug追踪，使用断言则是更好的选择。
 */

@interface PBExceptionController ()

@end

@implementation PBExceptionController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 异常
    {
        @try {
            // 可能会抛出异常的代码
            NSArray *array = @[@"Element"];
            [array objectAtIndex:1];
        } @catch (NSException *exception) {
            // 捕获异常
            NSLog(@"Caught an exception: %@", exception);
        } @finally {
            // 清理代码，不管是否发生异常都会执行
        }
    }
    
    {
        @try {
            NSException *exception = [NSException exceptionWithName:@"UBC单条日志大小超限" 
                                                             reason:@"主动抛异常"
                                                           userInfo:nil];
            @throw exception;
        } @catch (NSException *exception) {
            // 捕获异常
            NSLog(@"Caught an exception: %@", exception);
        } @finally {
            // 清理代码，不管是否发生异常都会执行
        }
    }
    
    {
        @try {
            NSException *exception = [NSException exceptionWithName:@"UBC单条日志大小超限" 
                                                             reason:@"主动抛异常"
                                                           userInfo:nil];
            [exception raise];
        } @catch (NSException *exception) {
            // 捕获异常
            NSLog(@"Caught an exception: %@", exception);
        } @finally {
            // 清理代码，不管是否发生异常都会执行
        }
    }
    
    {
        // 可以抛异常，但是无法捕获
        // @throw NSRangeException;
    }
    
    {
        // 可以抛异常，但是无法捕获
        // @throw nil;
    }
    
    {
        // 可以抛异常，但是无法捕获
        // @throw requires an Objective-C object type ('int' invalid)
        // @throw @222222;
    }
    
    // 断言
    {
        /**
         用于开发阶段调试程序中的Bug，通过为NSAssert()传递条件表达式来断定是否属于Bug。满足条件返回真值，程序继续运行，如果返回假值，则抛异常，并且可以自定义异常描述。
         */
        @try {
            NSArray *array = @[];
            NSAssert(array.count > 0, @"Array must not be empty");
        } @catch (NSException *exception) {
            // 捕获异常
            NSLog(@"Caught an exception: %@", exception);
        } @finally {
            // 清理代码，不管是否发生异常都会执行
        }
    }
}

@end
