//
//  UIViewController+PBCurrentVC.m
//  TestOC
//
//  Created by matrix on 2023/3/10.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "UIViewController+PBCurrentVC.h"

@implementation UIViewController (PBCurrentVC)

- (UIViewController *)bba_currentTopViewController {
    UIViewController *result;
    result = [self _bba_topViewController:self];
    while (result.presentedViewController) {
        result = [self _bba_topViewController:result.presentedViewController];
    }
    if (!result) {
        result = self;
    }
    return result;
}

- (UIViewController *)_bba_topViewController:(id)vc {
    Class tabBar = NSClassFromString(@"BBATabBarController");
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _bba_topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]] ||
               [vc isKindOfClass:tabBar]) {
        return [self _bba_topViewController:[(UITabBarController *)vc selectedViewController]];
    } if ([vc isKindOfClass:[UIWindow class]] && [vc respondsToSelector:@selector(bba_currentTopViewController)]) {
        return [vc bba_currentTopViewController];
    }
//    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
//               && ([vc isKindOfClass:[UISplitViewController class]]
//               || [vc isKindOfClass:NSClassFromString(@"BBASplitController")])) {
//        return [self _bba_topViewController:[self _bba_splitTopViewContoller:vc]];
//    }
    else if ([vc isKindOfClass:[UIViewController class]]) {
        return vc;
    } else {
        return nil;
    }
}

@end
