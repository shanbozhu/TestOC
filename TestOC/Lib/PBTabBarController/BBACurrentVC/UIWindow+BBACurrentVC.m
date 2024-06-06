//
//  UIWindow+BBAUtility.m
//  BBAPods
//
//  Created by huangjl on 15/4/16.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import "UIWindow+BBACurrentVC.h"
#import "UIViewController+BBACurrentVC.h"

@implementation UIWindow(BBACurrentVC)

- (UIViewController *)_bba_currentRootViewController {
    UIViewController *rootvVC = [self rootViewController];
    if (rootvVC) {
        return rootvVC;
    } else if (self.subviews.count > 0) {
        UIView *frontView = [self.subviews objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return nextResponder;
        }
    }
    return nil;
}

// 获取当前屏幕显示的viewcontroller
- (UIViewController *)bba_currentTopViewController {
    UIViewController *rootVC = [self _bba_currentRootViewController];
    if (rootVC) {
        return [rootVC bba_currentTopViewController];
    }
    return nil;
}

- (BOOL)bba_currentTopViewControllerIsPresent {
    UIViewController *rootVC = [self _bba_currentRootViewController];
    if (rootVC) {
        return [rootVC bba_currentTopViewControllerIsPresent];
    }
    return NO;
}

- (UIViewController *)bba_currentTabbarViewController {
    UIViewController *rootVC = [self _bba_currentRootViewController];
    if (rootVC) {
        return [rootVC bba_currentTabbarViewController];
    }
    return nil;
}

- (UINavigationController *)bba_topNavigationController {
    UIViewController *rootVC = [self _bba_currentRootViewController];
    if (rootVC) {
        return [rootVC bba_currentNavigationController];
    } 
    return nil;
}

+ (UIWindow *)_bba_currentWindow {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (!window || window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    return window;
}

+ (UIViewController *)bba_tabbarViewController {
    return [[UIWindow _bba_currentWindow] bba_currentTabbarViewController];
}

+ (UIViewController *)bba_topViewController {
    return [[UIWindow _bba_currentWindow] bba_currentTopViewController];
}

+ (BOOL)bba_topViewControllerIsPresent {
    return [[UIWindow _bba_currentWindow] bba_currentTopViewControllerIsPresent];
}

+ (UINavigationController *)bba_topNavigationController {
    return [[UIWindow _bba_currentWindow] bba_topNavigationController];
}

- (UIView *)bba_findFirstResponder {
    return [self bba_findFirstResponderInView:self];
}

- (UIView *)bba_findFirstResponderInView:(UIView*)topView {
    if ([topView isFirstResponder]) {
        return topView;
    }
    
    for (UIView* subView in topView.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }
        
        UIView* firstResponderCheck = [self bba_findFirstResponderInView:subView];
        if (nil != firstResponderCheck) {
            return firstResponderCheck;
        }
    }
    return nil;
}

@end
