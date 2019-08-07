//
//  PBGesturePasswordController.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/7/23.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBGesturePasswordController.h"
#import "PBGesturePasswordView.h"

@interface PBGesturePasswordController ()

@end

@implementation PBGesturePasswordController

- (BOOL)pb_panGestureRecognizerEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    PBGesturePasswordView *gesturePasswordView = [PBGesturePasswordView gesturePasswordView];
    [self.view addSubview:gesturePasswordView];
    gesturePasswordView.frame = self.view.bounds;
}

@end
