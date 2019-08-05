//
//  PBGCDListFourteenController.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2018/12/3.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBGCDListFourteenController.h"

@interface PBGCDListFourteenController ()

@end

@implementation PBGCDListFourteenController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(14)队列组";
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    NSLog(@"开始所有执行");
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1 == %@", [NSThread currentThread]);
        
        NSLog(@"开始执行1");
        sleep(2);
        NSLog(@"完成执行1");
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2 == %@", [NSThread currentThread]);
        
        NSLog(@"开始执行2");
        sleep(5);
        NSLog(@"完成执行2");
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"3 == %@", [NSThread currentThread]);
        
        NSLog(@"完成执行3");
    });
    
    NSLog(@"完成所有执行");
}

-(void)dealloc {
    NSLog(@"PBGCDListFourteenController对象被释放了");
}

@end
