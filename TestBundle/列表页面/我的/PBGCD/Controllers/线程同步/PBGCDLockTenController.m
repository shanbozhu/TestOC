//
//  PBGCDLockTenController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/10/31.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDLockTenController.h"
#import <pthread.h>

@interface PBGCDLockTenController () {
    pthread_rwlock_t _lock;
}

@end

@implementation PBGCDLockTenController

- (id)init {
    if ([super init]) {
        pthread_rwlock_init(&_lock, NULL);
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
        lab.text = @"(10)pthread_rwlock_t";
    }
    
    //当读写锁被一个线程以读模式占用的时候,写操作的其他线程会被阻塞,读操作的其他线程还可以继续进行.
    //当读写锁被一个线程以写模式占用的时候,写操作的其他线程会被阻塞,读操作的其他线程也被阻塞.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self testMultiThread];
}

- (void)testMultiThread {
    NSLog(@"开始所有执行");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self readOperationWithTag:1];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self readOperationWithTag:2];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self writeOperationWithTag:3];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self writeOperationWithTag:4];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self readOperationWithTag:5];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self readOperationWithTag:6];
    });
    
    NSLog(@"完成所有执行");
}

- (void)readOperationWithTag:(NSInteger)tag {
    pthread_rwlock_rdlock(&_lock);
    NSLog(@"开始执行%ld", tag);
    sleep(2);
    NSLog(@"完成执行%ld", tag);
    pthread_rwlock_unlock(&_lock);
}

- (void)writeOperationWithTag:(NSInteger)tag {
    pthread_rwlock_wrlock(&_lock);
    NSLog(@"开始执行%ld", tag);
    sleep(2);
    NSLog(@"完成执行%ld", tag);
    pthread_rwlock_unlock(&_lock);
}

- (void)dealloc {
    NSLog(@"PBGCDLockTenController对象被释放了");
}

@end
