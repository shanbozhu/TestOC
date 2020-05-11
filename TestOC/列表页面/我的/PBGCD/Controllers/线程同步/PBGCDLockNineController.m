//
//  PBGCDLockNineController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/30.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDLockNineController.h"

@interface PBGCDLockNineController () {
    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation PBGCDLockNineController

- (id)init {
    if ([super init]) {
        _lock = dispatch_semaphore_create(1);
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
        lab.text = @"(9)dispatch_semaphore_t";
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
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self deleteElement];
        });
    }
}

- (void)deleteElement {
    while (true) {
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); //只要信号量大于0就会执行此方法,执行此方法后信号量减1,当信号量减为0时其他线程就会等待
        if (self.arr.count > 0) {
            [self.arr removeLastObject];
        } else {
            NSLog(@"完成删除");
            dispatch_semaphore_signal(_lock);
            return;
        }
        dispatch_semaphore_signal(_lock); //执行此方法后信号量加1
    }
}

- (void)dealloc {
    NSLog(@"PBGCDLockNineController对象被释放了");
}

@end
