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
    IMP imp = class_getMethodImplementation(PBRuntimeSevenDebugController.class, @selector(run));
    class_addMethod(NSClassFromString(@"PBRuntimeSevenController"), @selector(run), imp, "v@:");
}

- (void)run {
    NSLog(@"----run----");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}



@end
