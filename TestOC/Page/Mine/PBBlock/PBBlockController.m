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

# pragma mark - JavaScript

/**
 var x = function (a, b) {
     return a + b
 };
 x(1, 2);

 var x = (a, b) => {
     return a + b
 };
 x(1, 2);
 
 // 自调用函数
 (function (a, b) {
     return a + b
 })(1, 2);
 */

# pragma mark - Swift

/**
 let closure: (Int, Int) -> Int = { (a: Int, b: Int) -> Int in
     return a + b
 }
 closure(1, 2)
 */

# pragma mark - OC

/**
 下面写法,Swift语法允许
 
- (NSInteger)stepForward:(NSInteger)a stepBackward:(NSInteger)b {
    return a + b;
}

- (NSInteger(^)(NSInteger a, NSInteger b))chooseStepFunction {
    return stepForward:stepBackward:;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger(^block)(NSInteger a, NSInteger b) = [self chooseStepFunction];
    block(1, 2);
}
 */

// block作为返回类型
// block作为形参类型
- (NSInteger(^)(NSInteger a, NSInteger b))funcParam1:(NSInteger(^)(NSInteger a, NSInteger b))block {
    return block;
}

- (NSInteger(^)(NSInteger a, NSInteger b))funcParam1 {
    __block NSInteger inner = 0;
    return ^NSInteger(NSInteger a, NSInteger b) {
        return inner += a;
    };
    
    NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
        return inner += a;
    };
    return block;
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
            inner = inner + 1;
            return inner;
        }];
        NSLog(@"block = %ld", block(1, 2));
        NSLog(@"block = %ld", block(1, 2));
        NSLog(@"block = %ld", block(1, 2));
        
        //
        NSInteger(^block1)(NSInteger a, NSInteger b) = [self funcParam1];
        NSLog(@"block1 = %ld", block1(1, 2));
        NSLog(@"block1 = %ld", block1(1, 2));
        NSLog(@"block1 = %ld", block1(1, 2));
        
        //
        block_t(^block2)(void) = ^block_t(void) {
            __block NSInteger inner = 0;
            return ^NSInteger (NSInteger a, NSInteger b) {
                return inner += a;
            };
        };
        block_t block3 = block2();
        NSLog(@"block3 = %ld", block3(1, 2));
        NSLog(@"block3 = %ld", block3(1, 2));
        NSLog(@"block3 = %ld", block3(1, 2));
        
        //
        block_t block4 = (^block_t(void) {
            __block NSInteger inner = 0;
            return ^NSInteger (NSInteger a, NSInteger b) {
                return inner += a;
            };
        })();
        NSLog(@"block4 = %ld", block4(1, 2));
        NSLog(@"block4 = %ld", block4(1, 2));
        NSLog(@"block4 = %ld", block4(1, 2));
    }
}

@end
