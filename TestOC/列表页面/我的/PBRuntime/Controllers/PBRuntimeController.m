//
//  PBRuntimeController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/9/11.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeController.h"


@interface PBRuntimeController ()

@end

/**
 假设此类中的代码不可修改
 */
@implementation PBRuntimeController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"[对象方法]被执行了2");
    
    [PBRuntimeController func];
}

+ (void)func {
    NSLog(@"[类方法]被执行了2");
}

@end
