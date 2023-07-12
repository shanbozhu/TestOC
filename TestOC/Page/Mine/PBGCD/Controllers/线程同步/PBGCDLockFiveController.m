//
//  PBGCDLockFiveController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/30.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDLockFiveController.h"
#import <pthread.h>

@interface PBGCDLockFiveController () {
    pthread_mutex_t _lock;
}

@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation PBGCDLockFiveController

- (instancetype)init {
    if ([super init]) {
        pthread_mutex_init(&_lock, NULL);
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
        lab.text = @"(5)pthread_mutex_t";
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
        pthread_mutex_lock(&_lock);
        if (self.arr.count > 0) {
            [self.arr removeLastObject];
        } else {
            NSLog(@"完成删除");
            pthread_mutex_unlock(&_lock);
            return;
        }
        pthread_mutex_unlock(&_lock);
    }
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
    
    NSLog(@"PBGCDLockFiveController对象被释放了");
}

@end
