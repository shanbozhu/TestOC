//
//  PBBlockController.m
//  TestOC
//
//  Created by shanbo on 2023/8/7.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBBlockController.h"

typedef NSInteger(^block_t)(NSInteger a, NSInteger b); // block类型定义

@interface PBBlockController ()

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSInteger(^block)(NSInteger a, NSInteger b); // block作为属性

@end

@implementation PBBlockController

// block作为返回类型
// block作为形参类型
- (NSInteger(^)(NSInteger a, NSInteger b))funcParam1:(NSInteger(^)(NSInteger a, NSInteger b))block param2:(block_t)param2 {
    return param2;
}

- (NSInteger(^)(NSInteger a, NSInteger b))funcParam1 {
    __block NSInteger inner = 0;
    NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
        return inner += a;
    };
    return block;
    
    return ^NSInteger(NSInteger a, NSInteger b) {
        return inner += a;
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        // 传值
        NSInteger value = 100;
        NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
            NSLog(@"value = %ld", value);
            return a + b;
        };
        value = 200;
        block(1, 2); // 输出100
    }
    
    {
        // 传地址
        static NSInteger value = 100;
        static NSInteger value1 = 100;
        NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
            value1 = 200;
            NSLog(@"value = %ld, value1 = %ld", value, value1);
            return a + b;
        };
        value = 200;
        block(1, 2); // 输出200
    }
    
    {
        // 传地址
        __block NSInteger value = 100;
        __block NSInteger value1 = 100;
        NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
            value1 = 200;
            NSLog(@"value = %ld, value1 = %ld", value, value1);
            return a + b;
        };
        value = 200;
        block(1, 2); // 输出200
    }
    
    {
        __weak typeof(self) weakSelf = self;
        NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.name = @"name"; // 弱引用self
            _name = @"name"; // 强引用self
            return a + b;
        };
        block(1, 2); // 输出200
    }
    
    {
        __block NSInteger inner = 0;
        NSInteger(^block)(NSInteger a, NSInteger b) = [self funcParam1:^NSInteger(NSInteger a, NSInteger b) {
            NSLog(@"没有被回调");
            return a + b;
        } param2:^NSInteger(NSInteger a, NSInteger b) {
            inner = inner + 1;
            return inner;
        }];
        NSLog(@"%ld", block(1, 2));
        NSLog(@"%ld", block(1, 2));
        NSLog(@"%ld", block(1, 2));
        
        
        NSInteger(^block1)(NSInteger a, NSInteger b) = [self funcParam1];
        NSLog(@"%ld", block1(1, 2));
        NSLog(@"%ld", block1(1, 2));
        NSLog(@"%ld", block1(1, 2));
    }
}

@end
