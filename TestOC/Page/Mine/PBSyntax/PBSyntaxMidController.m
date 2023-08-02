//
//  PBSyntaxMidController.m
//  TestOC
//
//  Created by shanbo on 2023/8/1.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBSyntaxMidController.h"

#define TestMacro @"PBSyntaxMidController"

@interface PBSyntaxMidController ()

@end

@implementation PBSyntaxMidController

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    NSLog(@"调用PBSyntaxMidController的setupUI");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"TestMacro = %@", TestMacro);
}

@end
