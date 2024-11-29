//
//  PBGCDListNineController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/29.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDListNineController.h"

@interface PBGCDListNineController ()

@end

@implementation PBGCDListNineController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(9)线程通信";
    }
    
    /**
     ------------ 开始所有执行
     ------------ 完成所有执行
     ------------ 1 == <NSThread: 0x282645e00>{number = 10, name = (null)}
     ------------ 11 == <NSThread: 0x28267c300>{number = 11, name = (null)}
     ------------ 111 == <NSThread: 0x282678cc0>{number = 12, name = (null)}
     ------------ 2 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 3 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 4 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ PBGCDListNineController对象被释放了
     
     ------------ 开始所有执行
     ------------ 完成所有执行
     ------------ 11 == <NSThread: 0x282678cc0>{number = 12, name = (null)}
     ------------ 1 == <NSThread: 0x28267db40>{number = 14, name = (null)}
     ------------ 111 == <NSThread: 0x282665580>{number = 15, name = (null)}
     ------------ 2 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 3 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 4 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ PBGCDListNineController对象被释放了
     
     ------------ 开始所有执行
     ------------ 完成所有执行
     ------------ 1 == <NSThread: 0x28267d100>{number = 27, name = (null)}
     ------------ 111 == <NSThread: 0x2826687c0>{number = 26, name = (null)}
     ------------ 11 == <NSThread: 0x28266fe00>{number = 25, name = (null)}
     ------------ 2 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 3 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 4 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ PBGCDListNineController对象被释放了
     
     ------------ 开始所有执行
     ------------ 完成所有执行
     ------------ 11 == <NSThread: 0x28267a1c0>{number = 30, name = (null)}
     ------------ 1 == <NSThread: 0x28267b880>{number = 31, name = (null)}
     ------------ 111 == <NSThread: 0x282678c80>{number = 32, name = (null)}
     ------------ 3 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 2 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 4 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ PBGCDListNineController对象被释放了
     
     ------------ 开始所有执行
     ------------ 完成所有执行
     ------------ 1 == <NSThread: 0x28267c140>{number = 41, name = (null)}
     ------------ 11 == <NSThread: 0x2826625c0>{number = 43, name = (null)}
     ------------ 111 == <NSThread: 0x2826630c0>{number = 44, name = (null)}
     ------------ 3 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 2 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ 4 == <NSThread: 0x2826cee80>{number = 1, name = main}
     ------------ PBGCDListNineController对象被释放了
     */
    
    NSLog(@"开始所有执行");
    
    // 子线程下载，主线程填充
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1 == %@", [NSThread currentThread]);
        
        sleep(3);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"2 == %@", [NSThread currentThread]);
        });
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"11 == %@", [NSThread currentThread]);
        
        sleep(3);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"3 == %@", [NSThread currentThread]);
        });
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"111 == %@", [NSThread currentThread]);
        
        sleep(5);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"4 == %@", [NSThread currentThread]);
        });
    });
    
    NSLog(@"完成所有执行");
}

- (void)dealloc {
    NSLog(@"PBGCDListNineController对象被释放了");
}

@end
