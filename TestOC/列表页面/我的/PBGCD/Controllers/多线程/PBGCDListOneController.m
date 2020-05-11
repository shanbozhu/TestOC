//
//  PBGCDListOneController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/27.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDListOneController.h"

@interface PBGCDListOneController ()

@end

@implementation PBGCDListOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(1)并行队列 + 同步执行";
    }
    
    dispatch_queue_t queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"开始所有执行");
    
    dispatch_sync(queue, ^{ // 把[block任务]加到[并行队列]中[同步执行]
        NSLog(@"1 == %@", [NSThread currentThread]);
        
        NSLog(@"开始执行1");
        sleep(2);
        NSLog(@"完成执行1");
    });
    
    NSLog(@"开始中间执行");
    
    dispatch_sync(queue, ^{
        NSLog(@"2 == %@", [NSThread currentThread]);
        
        NSLog(@"开始执行2");
        sleep(2);
        NSLog(@"完成执行2");
    });

    NSLog(@"完成所有执行");
}

-(void)dealloc {
    NSLog(@"PBGCDListOneController对象被释放了");
}

@end
