//
//  PBBlockController.m
//  TestOC
//
//  Created by shanbo on 2023/8/7.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBBlockController.h"

@interface PBBlockController ()

@property (nonatomic, copy) NSString *name;

@end

@implementation PBBlockController

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
            weakSelf.name = @"name"; // 弱引用self
            _name = @"name"; // 强引用self
            return a + b;
        };
        block(1, 2); // 输出200
    }
}



@end
