//
//  UIView+PBCommonExtension.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/3/25.
//  Copyright © 2019年 Baidu. All rights reserved.
//

#import "UIView+PBCommonExtension.h"

@implementation UIView (PBCommonExtension)

- (CGFloat)pb_left {
    return self.frame.origin.x;
}

- (void)pb_setLeft:(CGFloat)pb_left {
    CGRect frame = self.frame;
    frame.origin.x = pb_left;
    self.frame = frame;
}

- (CGFloat)pb_top {
    return self.frame.origin.y;
}

- (void)pb_setTop:(CGFloat)pb_top {
    CGRect frame = self.frame;
    frame.origin.y = pb_top;
    self.frame = frame;
}

- (CGFloat)pb_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)pb_setRight:(CGFloat)pb_right {
    CGRect frame = self.frame;
    frame.origin.x = pb_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)pb_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)pb_setBottom:(CGFloat)pb_bottom {
    CGRect frame = self.frame;
    frame.origin.y = pb_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)pb_centerX {
    return self.center.x;
}

- (void)pb_setCenterX:(CGFloat)pb_centerX {
    self.center = CGPointMake(pb_centerX, self.center.y);
}

- (CGFloat)pb_centerY {
    return self.center.y;
}

- (void)pb_setCenterY:(CGFloat)pb_centerY {
    self.center = CGPointMake(self.center.x, pb_centerY);
}

- (CGFloat)pb_width {
    return self.frame.size.width;
}

- (void)pb_setWidth:(CGFloat)pb_width {
    CGRect frame = self.frame;
    frame.size.width = pb_width;
    self.frame = frame;
}

- (CGFloat)pb_height {
    return self.frame.size.height;
}

- (void)pb_setHeight:(CGFloat)pb_height {
    CGRect frame = self.frame;
    frame.size.height = pb_height;
    self.frame = frame;
}

- (CGPoint)pb_origin {
    return self.frame.origin;
}

- (void)pb_setOrigin:(CGPoint)pb_origin {
    CGRect frame = self.frame;
    frame.origin = pb_origin;
    self.frame = frame;
}

- (CGSize)pb_size {
    return self.frame.size;
}

- (void)pb_setSize:(CGSize)pb_size {
    CGRect frame = self.frame;
    frame.size = pb_size;
    self.frame = frame;
}

@end
