//
//  PBArrayTraversalController.m
//  TestOC
//
//  Created by shanbo on 2023/3/6.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBArrayTraversalController.h"

@interface PBArrayTraversalController ()

@end

@implementation PBArrayTraversalController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     参考文档:
     iOS-enumerateObjectsUsingBlock跳出循环 https://www.jianshu.com/p/a48c01ac2e36
     iOS enumerateObjectsUsingBlock 循环停止问题 https://blog.csdn.net/LIUXIAOXIAOBO/article/details/111311686
     */
    
    {
        /**
         打印如下:
         ------------ obj = 1
         ------------ obj = 2
         ------------ obj = 3
         ------------ tmp = 3
         
         【不推荐】
         只用 *stop = YES; 相当于break的用法,但是有一点区别当前循环会执行完成
         */
        NSArray *objs = @[@"1" , @"2", @"3", @"4", @"5"];
        __block NSString *tmp = nil;
        [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:@"3"]) {
                tmp = obj;
                *stop = YES;
            }
            NSLog(@"obj = %@", obj);
        }];
        NSLog(@"tmp = %@", tmp);
    }
    
    {
        /**
         打印如下:
         ------------ obj = 1
         ------------ obj = 2
         ------------ obj = 4
         ------------ obj = 5
         ------------ tmp = 3
         
         只用 return; 相当于continue的用法
         */
        NSArray *objs = @[@"1" , @"2", @"3", @"4", @"5"];
        __block NSString *tmp = nil;
        [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:@"3"]) {
                tmp = obj;
                return;
            }
            NSLog(@"obj = %@", obj);
        }];
        NSLog(@"tmp = %@", tmp);
    }
    
    {
        /**
         打印如下:
         ------------ obj = 1
         ------------ obj = 2
         ------------ tmp = 3
         
         【强烈推荐】
         *stop = YES; 和 return; 连用,相当于break的用法
         */
        NSArray *objs = @[@"1" , @"2", @"3", @"4", @"5"];
        __block NSString *tmp = nil;
        [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:@"3"]) {
                tmp = obj;
                *stop = YES;
                return;
            }
            NSLog(@"obj = %@", obj);
        }];
        NSLog(@"tmp = %@", tmp);
    }
}


@end
