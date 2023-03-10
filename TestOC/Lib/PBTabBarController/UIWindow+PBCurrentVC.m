//
//  UIWindow+PBCurrentVC.m
//  TestOC
//
//  Created by matrix on 2023/3/10.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "UIWindow+PBCurrentVC.h"
#import "UIViewController+PBCurrentVC.h"

@implementation UIWindow (PBCurrentVC)

+ (UIViewController *)bba_topViewController {
    return [[UIWindow _bba_currentWindow] bba_currentTopViewController];
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

- (UIViewController *)bba_currentTopViewController {
    UIViewController *rootVC = [self _bba_currentRootViewController];
    if (rootVC) {
        return [rootVC bba_currentTopViewController];
    }
    return nil;
}

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

@end
