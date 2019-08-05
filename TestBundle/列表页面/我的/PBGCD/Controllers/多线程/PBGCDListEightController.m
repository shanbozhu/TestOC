//
//  PBGCDListEightController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/10/27.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDListEightController.h"

@interface PBGCDListEightController ()

@end

@implementation PBGCDListEightController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(8)主串行队列 + 异步执行";
    }
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    NSLog(@"开始所有执行");
    
    dispatch_async(queue, ^{
        NSLog(@"1 == %@", [NSThread currentThread]);
        
        NSLog(@"开始执行1");
        sleep(2);
        NSLog(@"完成执行1");
    });
    
    NSLog(@"开始中间执行");
    
    dispatch_async(queue, ^{
        NSLog(@"2 == %@", [NSThread currentThread]);
        
        NSLog(@"开始执行2");
        sleep(2);
        NSLog(@"完成执行2");
    });
    
    NSLog(@"完成所有执行");
}

-(void)dealloc {
    NSLog(@"PBGCDListEightController对象被释放了");
}

@end
