//
//  PBNavigationController.m
//  陪伴Ta
//
//  Created by DaMaiIOS on 15/8/4.
//  Copyright (c) 2015年 朱善波. All rights reserved.
//

#import "PBNavigationController.h"

@interface PBNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation PBNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //屏蔽系统边缘侧滑
    self.interactivePopGestureRecognizer.enabled = NO;
    
    
    //代理变量具体化 自己作为自己的代理
    self.delegate = self;
    
    
    //全屏侧滑(本质是替换 委托方法)
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
    self.pan = pan;
    [self.view addGestureRecognizer:pan];
    pan.delegate = self;
}

-(void)handleNavigationTransition:(UIPanGestureRecognizer *)pan {
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count == 1) {
        return NO;
    }
    return YES;
}

@end
