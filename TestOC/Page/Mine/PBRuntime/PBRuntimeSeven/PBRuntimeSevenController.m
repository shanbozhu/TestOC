//
//  PBRuntimeSevenController.m
//  TestOC
//
//  Created by shanbo on 2024/4/23.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeSevenController.h"

@interface PBRuntimeSevenController ()

@end

@implementation PBRuntimeSevenController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 执行实例方法(对象)
    [self performSelector:@selector(strategyDetailWithTapClick) withObject:@"this"];
    // 执行类方法(类对象)
//    [PBRuntimeFiveController performSelector:@selector(strategyDetailWithTapClick) withObject:@"world"];
}



@end
