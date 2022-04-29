//
//  PBChannelController.m
//  TestOC
//
//  Created by DaMaiIOS on 16/9/20.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBChannelController.h"

@interface PBChannelController ()

@end

@implementation PBChannelController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}

@end
