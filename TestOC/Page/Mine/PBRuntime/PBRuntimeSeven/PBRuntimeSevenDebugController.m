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
    // 方案一
    IMP imp = class_getMethodImplementation(NSClassFromString(@"PBRuntimeSevenDebugController"), @selector(run));
    class_addMethod(NSClassFromString(@"PBRuntimeSevenController"), @selector(run), imp, "v@:");
    
    // 方案二
    Method method = class_getInstanceMethod(NSClassFromString(@"PBRuntimeSevenDebugController"), @selector(func:));
    class_addMethod(NSClassFromString(@"PBRuntimeSevenController"), @selector(func:), method_getImplementation(method), method_getTypeEncoding(method));
}

- (void)run {
    NSLog(@"----run----");
}

- (void)func:(NSString *)name {
    NSLog(@"----func----, name = %@", name);
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
