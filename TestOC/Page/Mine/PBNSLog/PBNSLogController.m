//
//  PBNSLogController.m
//  TestOC
//
//  Created by shanbo on 2024/5/8.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBNSLogController.h"

@interface PBNSLogController ()

@end

@implementation PBNSLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    NSUInteger age = 18;
    NSLog(@"age = %lu", age);
    NSLog(@"age = %hd", age);
    NSLog(@"age = %hu", age);
    
    //
    CGFloat height = 18.012345;
    NSLog(@"height = %.3lf", height);
    
    //
    NSInteger aa = 1000;
    NSLog(@"aa = %lx", aa);
    NSLog(@"aa = %lX", aa);
    NSLog(@"aa = %lo", aa);
    NSLog(@"aa = %lO", aa);
    NSLog(@"aa = %b", aa);
    
    
    int number = 25; // 十进制数25
    NSLog(@"%d in binary is %i", number, number); // 打印二进制表示
    
    // 除k取余法
    // 乘以k的次方
}



@end
