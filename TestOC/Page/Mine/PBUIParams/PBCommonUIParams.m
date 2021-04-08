//
//  PBCommonUIParams.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/8.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBCommonUIParams.h"

@implementation PBCommonUIParams

+ (CGFloat)statusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (CGFloat)navigationBarHeight {
    return [PBCommonUIParams statusBarHeight] + APPLICATION_NAVIGATIONBAR_CONTENT_HEIGHT;
}

+ (CGFloat)tabBarHeight {
    return [PBCommonUIParams safeBottomMargin] + APPLICATION_TABBAR_CONTENT_HEIGHT;
}

+ (CGFloat)applicationFrameWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)applicationFrameHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (UIEdgeInsets)safeMargin {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

+ (BOOL)isFringeScreen {
    UIEdgeInsets edge = [PBCommonUIParams safeMargin];
    return !(edge.bottom == 0 && edge.left == 0 && edge.right == 0);
}

+ (CGFloat)safeTopMargin {
    return [PBCommonUIParams safeMargin].top;
}

+ (CGFloat)safeBottomMargin {
    return [PBCommonUIParams safeMargin].bottom;
}

+ (CGFloat)safeLeftMargin {
    return [PBCommonUIParams safeMargin].left;
}

+ (CGFloat)safeRightMargin {
    return [PBCommonUIParams safeMargin].right;
}

@end
