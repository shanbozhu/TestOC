//
//  PBRuntimeSevenDebugController.m
//  TestOC
//
//  Created by shanbo on 2024/4/23.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeSevenDebugController.h"

@interface PBRuntimeSevenDebugController ()

@end

@implementation PBRuntimeSevenDebugController

+ (void)load {
    IMP imp = class_getMethodImplementation(PBRuntimeSevenDebugController.class, @selector(strategyDetailWithTapClick1));
    class_addMethod(NSClassFromString(@"PBRuntimeSevenController"), @selector(strategyDetailWithTapClick), imp, "v@:");
}

- (void)strategyDetailWithTapClick1 {
    NSLog(@"haha");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}



@end
