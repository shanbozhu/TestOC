//
//  PBAnimationStateButton.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/27.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationStateButton.h"

@implementation PBAnimationStateButton

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self btnDidTouchEndedOrCancelled];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self btnDidTouchEndedOrCancelled];
}

- (void)btnDidTouchEndedOrCancelled {
    if ([self.delegate respondsToSelector:@selector(animationStateButtonDidTouchEndedOrCancelled:)]) {
        [self.delegate animationStateButtonDidTouchEndedOrCancelled:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 设置部分圆角
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                     byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight
                                                           cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = bezierPath.CGPath;
    self.layer.mask = maskLayer;
}

@end
