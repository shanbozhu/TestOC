//
//  UIViewController+BBACurrentVC.h
//  BBAPods
//
//  Created by jilutao on 18/1/31.
//  Copyright (c) 2018 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BBACurrentVC)

// 当前展示的VC
- (UIViewController *)bba_currentTopViewController;

// 当前展示的VC（过滤正在dismiss的VC）
- (UIViewController *)bba_currentTopViewControllerWithoutDismissing;

- (UIViewController *)bba_currentTabbarViewController;

- (BOOL)bba_currentTopViewControllerIsPresent;
// 当前栈顶的VC, 不包含modal出来的VC
- (UIViewController *)bba_currentStackTopViewController;

- (UINavigationController *)bba_currentNavigationController;

@end
