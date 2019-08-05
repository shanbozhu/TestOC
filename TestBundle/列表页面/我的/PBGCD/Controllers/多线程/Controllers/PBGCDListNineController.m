//
//  PBGCDListNineController.m
//  TestBundle
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
    
    NSLog(@"开始所有执行");
    
    // 子线程下载,主线程填充
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1 == %@", [NSThread currentThread]);
        
        sleep(3);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"2 == %@", [NSThread currentThread]);
        });
    });
    
    NSLog(@"完成所有执行");
}

-(void)dealloc {
    NSLog(@"PBGCDListNineController对象被释放了");
}

@end
