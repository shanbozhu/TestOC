//
//  UIView+UIViewExt.m
//  RenrenCore
//
//  Created by Winston on 11-5-20.
//  Copyright 2011年 www.renren.com. All rights reserved.
//

#import "UIView+BBACurrentVC.h"

@implementation UIView(BBACurrentVC)

- (UIViewController*)bba_currentViewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end
