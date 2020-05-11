//
//  PBGCDListTwelveController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/29.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDListTwelveController.h"

@interface PBGCDListTwelveController ()

@end

@implementation PBGCDListTwelveController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(12)一次性方法";
    }
    
    NSLog(@"开始所有执行");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"1 == %@", [NSThread currentThread]);
        
        NSLog(@"完成执行1");
    });
    
    NSLog(@"完成所有执行");
}

-(void)dealloc {
    NSLog(@"PBGCDListTwelveController对象被释放了");
}

@end
