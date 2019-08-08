//
//  PBBaseController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/10/7.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBBaseController.h"

@implementation UIViewController (PBNavigationBar)

- (BOOL)pb_navigationBarHidden {
    return NO;
}

- (BOOL)pb_panGestureRecognizerEnabled {
    return YES;
}

- (BOOL)pb_popGestureRecognizerEnabled {
    return YES;
}

@end

@implementation PBBaseController

// 是否显示导航栏
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:[self pb_navigationBarHidden] animated:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.navigationController.viewControllers.count == 1) {
        return NO;
    }
    return YES;
}

// 是否使能侧滑
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self pb_popGestureRecognizerEnabled] == NO) {
        self.navigationController.interactivePopGestureRecognizer.enabled = [self pb_popGestureRecognizerEnabled];
        
        if ([self.navigationController respondsToSelector:@selector(pan)]) {
            [[(PBNavigationController *)self.navigationController pan]setEnabled:[self pb_popGestureRecognizerEnabled]];
        }
    }
    
    if ([self pb_panGestureRecognizerEnabled] == NO) {
        if ([self.navigationController respondsToSelector:@selector(pan)]) {
            [[(PBNavigationController *)self.navigationController pan]setEnabled:[self pb_panGestureRecognizerEnabled]];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = [super pb_panGestureRecognizerEnabled];
    
    if ([self.navigationController respondsToSelector:@selector(pan)]) {
        [[(PBNavigationController *)self.navigationController pan]setEnabled:[super pb_panGestureRecognizerEnabled]];
    }
}

@end
