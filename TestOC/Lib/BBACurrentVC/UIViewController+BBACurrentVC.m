//
//  UIViewController+BBACurrentVC.h
//  BBAPods
//
//  Created by jilutao on 18/1/31.
//  Copyright (c) 2018年 Baidu. All rights reserved.
//

/*
 tips：
 获取顶部导航容器时bba_currentNavigationController中加入过滤当前导航容器处于dismiss的状态
 badcase：http://newicafe.baidu.com/issue/67404643/show?cid=5&spaceId=2615&from=email&noticeStatistics=11395807
 */
// !!!:其他函数未添加该判断进行过滤，原因：当前文件为公用基础库，文件中函数使用场景多，测试不易，且暂未发现异常，为防止修改带来新问题故其余函数暂不添加

#import "UIViewController+BBACurrentVC.h"

@implementation UIViewController(BBACurrentVC)

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
- (UIViewController *)bba_currentTopViewControllerWithoutDismissing {
    UIViewController *result;
    result = [self _bba_topViewController:self];
    while (result.presentedViewController && ![result.presentedViewController isBeingDismissed]) {
        result = [self _bba_topViewController:result.presentedViewController];
    }
    if (!result) {
        result = self;
    }
    return result;
}
- (UIViewController *)bba_currentTabbarViewController {
    UIViewController *result;
    result = [self _bba_tabbarViewController:self];
    while (result.presentedViewController) {
        result = [self _bba_tabbarViewController:result.presentedViewController];
    }
    if (!result) {
        result = self;
    }
    return result;
}
- (BOOL)bba_currentTopViewControllerIsPresent {
    BOOL result = NO;
    UIViewController *topVC = [self _bba_topViewController:self];
    if (topVC.presentedViewController) {
        result = YES;
    }
    return result;
}
- (UIViewController *)_bba_tabbarViewController:(id)vc {
    Class tabBar = NSClassFromString(@"BBATabBarController");
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _bba_tabbarViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]] ||
               [vc isKindOfClass:tabBar]) {
        return vc;
    } if ([vc isKindOfClass:[UIWindow class]] && [vc respondsToSelector:@selector(bba_currentTabbarViewController)]) {
        return [vc bba_currentTabbarViewController];
    } else {
        return nil;
    }
}
    
- (UIViewController *)bba_currentStackTopViewController {
    return [self _bba_topViewController:self];
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

//- (UIViewController *)_bba_splitTopViewContoller:(UISplitViewController *)splitViewController {
//    if (splitViewController.viewControllers.count == 0) {
//        return nil;
//    } else {
//        return splitViewController.viewControllers.lastObject;
//    }
//}
- (UINavigationController *)bba_currentNavigationController {
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        if ([self isKindOfClass:[UISplitViewController class]]
//            || [self isKindOfClass:NSClassFromString(@"BBASplitViewController")]) {
//            if (self.presentedViewController) {
//                if ([self.presentedViewController isKindOfClass:[UINavigationController class]]) {
//                    return (UINavigationController *)self.presentedViewController;
//                } else if (self.presentedViewController.navigationController){
//                    return self.presentedViewController.navigationController;
//                }
//            }
//            UIViewController *vc = [self _bba_splitTopViewContoller:(UISplitViewController *)self];
//            if ([vc isKindOfClass:[UINavigationController class]]) {
//                return (UINavigationController *)vc;
//            }
//        }
//    }
    
    UIViewController *topVC = [self _bba_topViewController:self];
    UINavigationController *topNavi = topVC.navigationController;
    while (topVC.presentedViewController && ![topVC.presentedViewController isBeingDismissed]) {
        topVC = [self _bba_topViewController:topVC.presentedViewController];
        if (topVC.navigationController) {
            topNavi = topVC.navigationController;
        }
    }
    if (!topNavi) {
        topNavi = self.navigationController;
    }
    return topNavi;
}

@end
