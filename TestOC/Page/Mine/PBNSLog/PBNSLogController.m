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
    
    // 十进制转k进制:除k取余法
    // k进制转十进制:乘以k的次方
    
    // 有效数字:从第一个不是0的数开始,以下都是
    // 00000018.012的有效数字是5
    
    // 十六进制:0x1f4
    // 八进制:0764
    
    // 十六进制小写:%x
    // 十六进制大写:%X
    // 八进制:%o
    
    // 总共显示12位,前面不足补0,小数点后显示3位小数:%012.3lf
    
    //
    CGFloat height = 18.012345;
    NSLog(@"height = %012.3lf", height); // 00000018.012
    NSLog(@"height = %0.3lf", height); // 18.012
    NSLog(@"height = %.3lf", height); // 18.012
    
    //
    NSInteger aa = 500;
    NSLog(@"aa = %lx", aa); // 1f4 = 4 * 16^0 + f * 16^1 + 1 * 16^2 = 500
    NSLog(@"aa = %lX", aa); // 1F4
    NSLog(@"aa = %lo", aa); // 764 = 4 * 8^0 + 6 * 8^1 + 7 * 8^2 = 500
}

@end
