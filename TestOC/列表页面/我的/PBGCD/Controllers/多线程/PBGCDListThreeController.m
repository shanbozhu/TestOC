//
//  PBGCDListThreeController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/27.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDListThreeController.h"

@interface PBGCDListThreeController ()

@end

@implementation PBGCDListThreeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(3)全局并行队列 + 同步执行";
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    NSLog(@"开始所有执行");
    
    dispatch_sync(queue, ^{
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
    NSLog(@"PBGCDListThreeController对象被释放了");
}

@end
