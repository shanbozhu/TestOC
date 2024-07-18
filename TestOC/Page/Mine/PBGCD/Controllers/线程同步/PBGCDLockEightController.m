//
//  PBGCDLockEightController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/30.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDLockEightController.h"

@interface PBGCDLockEightController () {
    dispatch_queue_t _queue;
}

@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation PBGCDLockEightController

- (instancetype)init {
    if ([super init]) {
        // 此种情况不能采用[全局并行队列]，否则会崩溃
        _queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(8)dispatch_barrier_async";
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self testMultiThread];
}

- (void)testMultiThread {
    self.arr = [NSMutableArray array];
    for (int i = 0; i < 10240; i++) {
        [self.arr addObject:@(i)];
    }
    
    for (int i = 0; i < 3; i++) {
        dispatch_barrier_async(_queue, ^{
            [self deleteElement];
        });
    }
}

- (void)deleteElement {
    while (true) {
        if (self.arr.count > 0) {
            [self.arr removeLastObject];
        } else {
            NSLog(@"完成删除");
            return;
        }
    }
}

- (void)dealloc {
    NSLog(@"PBGCDLockEightController对象被释放了");
}

@end
