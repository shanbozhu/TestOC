//
//  PBGCDListController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDListController.h"
#import "YYFPSLabel.h"

@interface PBGCDListController ()


@end

@implementation PBGCDListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(0)dispatch_group_enter";
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    NSLog(@"开始所有执行");
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ // 模拟网络请求
        NSLog(@"1 == %@", [NSThread currentThread]);
        
        NSLog(@"开始请求1");
        sleep(5);
        NSLog(@"完成请求1");
        dispatch_group_leave(group);
    });
    
    NSLog(@"开始中间执行");
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ // 模拟网络请求
        NSLog(@"2 == %@", [NSThread currentThread]);
        
        NSLog(@"开始请求2");
        sleep(8);
        NSLog(@"完成请求2");
        dispatch_group_leave(group);
    });
    
    // 需要放在dispatch_group_enter的后面
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"3 == %@", [NSThread currentThread]);
        
        NSLog(@"完成执行3");
    });
    
    NSLog(@"完成所有执行");
}

-(void)dealloc {
    NSLog(@"PBGCDListController对象被释放了");
}

@end
