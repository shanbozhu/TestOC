//
//  PBRuntimeZeroController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/9/11.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeZeroController.h"


@interface PBRuntimeZeroController ()

@end

@implementation PBRuntimeZeroController

- (void)viewDidLoad {
    [super viewDidLoad];
    [PBRuntimeZeroController func];
    [PBRuntimeZeroController run];
}

+ (void)func {
    NSLog(@"执行2. func");
}

+ (void)run {
    NSLog(@"执行2. run");
}

@end
