//
//  PBGCDLockController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/30.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDLockController.h"

@interface PBGCDLockController ()

@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation PBGCDLockController

- (void)viewDidLoad {
    [super viewDidLoad];

    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(0)不加锁";
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
        if (self.arr.count > 0) {
            [self.arr removeLastObject]; // 不加锁，线程不安全，会崩溃
        } else {
            NSLog(@"完成删除");
            return;
        }
    }
}

- (void)dealloc {
    NSLog(@"PBGCDLockController对象被释放了");
}

@end
