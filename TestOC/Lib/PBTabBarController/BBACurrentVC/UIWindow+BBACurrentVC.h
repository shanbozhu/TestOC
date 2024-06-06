//
//  UIWindow+BBACurrentVC.h
//  BBAPods
//
//  Created by huangjl on 15/4/16.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow(BBACurrentVC)

/**
 * @brief 获取当前屏幕显示的viewcontroller
 *
 * @return viewcontroller
 */
- (UIViewController *)bba_currentTopViewController;

+ (UIViewController *)bba_topViewController;

+ (BOOL)bba_topViewControllerIsPresent;

+ (UIViewController *)bba_tabbarViewController;

+ (UINavigationController *)bba_topNavigationController;

/**
 * Searches the view hierarchy recursively for the first responder, starting with this window.
 */
- (UIView *)bba_findFirstResponder;

/**
 * Searches the view hierarchy recursively for the first responder, starting with topView.
 */
- (UIView *)bba_findFirstResponderInView:(UIView*)topView;

@end
