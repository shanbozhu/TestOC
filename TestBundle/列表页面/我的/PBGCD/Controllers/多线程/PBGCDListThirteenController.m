//
//  PBGCDListThirteenController.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2018/12/3.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBGCDListThirteenController.h"

@interface PBGCDListThirteenController ()

@end

@implementation PBGCDListThirteenController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UILabel *lab = [[UILabel alloc] init];
        [self.view addSubview:lab];
        lab.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.text = @"(13)并行遍历";
    }
    
    NSArray *arr = @[@"hhh", @"hjij", @"hhh", @"ioo", @"erer", @"hhh", @"hjij", @"hhh", @"ioo", @"erer"];
    
    NSLog(@"开始所有执行");
    
    dispatch_apply(arr.count, dispatch_get_global_queue(0, 0), ^(size_t index) {
        NSLog(@"arr[index] = %@, 1 == %@", arr[index], [NSThread currentThread]);
        
        NSLog(@"完成执行1");
    });
    
    NSLog(@"完成所有执行");
}

-(void)dealloc {
    NSLog(@"PBGCDListThirteenController对象被释放了");
}

@end
