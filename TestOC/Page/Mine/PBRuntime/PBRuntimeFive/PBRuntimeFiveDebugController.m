//
//  PBRuntimeFiveDebugController.m
//  TestOC
//
//  Created by shanbo on 2024/4/19.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeFiveDebugController.h"

@interface PBRuntimeFiveDebugController ()

@end

@implementation PBRuntimeFiveDebugController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)run:(NSString *)name {
    NSLog(@"----run----, name = %@", name);
}

- (void)test:(NSString *)name {
    NSLog(@"----test-----, name = %@", name);
}

@end
