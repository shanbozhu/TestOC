//
//  UIView+CommonExtension.m
//  BBAFoundation
//
//  Created by Zhu,Yusong on 2019/3/25.
//  Copyright © 2019年 Baidu. All rights reserved.
//

#import "UIView+CommonExtension.h"


@implementation UIView (CommonExtension)

- (CGFloat)bba_left {
  return self.frame.origin.x;
}

- (void)bba_setLeft:(CGFloat)bba_left {
    CGRect frame = self.frame;
    frame.origin.x = bba_left;
    self.frame = frame;
}

- (CGFloat)bba_top {
  return self.frame.origin.y;
}

- (void)bba_setTop:(CGFloat)bba_top {
  CGRect frame = self.frame;
  frame.origin.y = bba_top;
  self.frame = frame;
}

- (CGFloat)bba_right {
  return self.frame.origin.x + self.frame.size.width;
}

- (void)bba_setRight:(CGFloat)bba_right {
  CGRect frame = self.frame;
  frame.origin.x = bba_right - frame.size.width;
  self.frame = frame;
}

- (CGFloat)bba_bottom {
  return self.frame.origin.y + self.frame.size.height;
}

- (void)bba_setBottom:(CGFloat)bba_bottom {
  CGRect frame = self.frame;
  frame.origin.y = bba_bottom - frame.size.height;
  self.frame = frame;
}

- (CGFloat)bba_centerX {
  return self.center.x;
}

- (void)bba_setCenterX:(CGFloat)bba_centerX {
  self.center = CGPointMake(bba_centerX, self.center.y);
}

- (CGFloat)bba_centerY {
  return self.center.y;
}

- (void)bba_setCenterY:(CGFloat)bba_centerY {
  self.center = CGPointMake(self.center.x, bba_centerY);
}

- (CGFloat)bba_width {
  return self.frame.size.width;
}

- (void)bba_setWidth:(CGFloat)bba_width {
  CGRect frame = self.frame;
  frame.size.width = bba_width;
  self.frame = frame;
}

- (CGFloat)bba_height {
  return self.frame.size.height;
}

- (void)bba_setHeight:(CGFloat)bba_height {
  CGRect frame = self.frame;
  frame.size.height = bba_height;
  self.frame = frame;
}

- (CGPoint)bba_origin {
  return self.frame.origin;
}

- (void)bba_setOrigin:(CGPoint)bba_origin {
  CGRect frame = self.frame;
  frame.origin = bba_origin;
  self.frame = frame;
}

- (CGSize)bba_size {
  return self.frame.size;
}

- (void)bba_setSize:(CGSize)bba_size {
  CGRect frame = self.frame;
  frame.size = bba_size;
  self.frame = frame;
}

@end
