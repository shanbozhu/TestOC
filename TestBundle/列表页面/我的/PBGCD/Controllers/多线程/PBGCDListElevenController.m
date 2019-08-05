//
//  PBGCDListElevenController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/10/29.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDListElevenController.h"

@interface PBGCDListElevenController ()

@end

@implementation PBGCDListElevenController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(11)延时方法";
    }
    
    NSLog(@"开始所有执行");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"1 == %@", [NSThread currentThread]);
        
        NSLog(@"完成执行1");
    });
    
    NSLog(@"完成所有执行");
}

-(void)dealloc {
    NSLog(@"PBGCDListElevenController对象被释放了");
}

@end
