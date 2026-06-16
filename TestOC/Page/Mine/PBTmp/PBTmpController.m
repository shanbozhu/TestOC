//
//  PBTmpController.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/10.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBTmpController.h"

@interface PBTmpController ()

@end

@implementation PBTmpController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = nil;
    NSLog(@"view.tag = %ld", view.tag);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(50, 100, 50, 50);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)btnClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ut.34400722://"] options:@{} completionHandler:^(BOOL success) {
        NSLog(@"success = %d", success);
    }];
}

@end
