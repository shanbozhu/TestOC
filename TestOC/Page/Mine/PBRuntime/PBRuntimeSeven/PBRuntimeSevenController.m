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
    
    // 方案一
    [self performSelector:@selector(run:a:) withObject:@"name" withObject:@(9527)];
    
    // 方案二
    [self performSelector:@selector(func:) withObject:@"func"];
}

@end
