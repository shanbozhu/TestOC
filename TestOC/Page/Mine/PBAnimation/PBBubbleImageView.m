//
//  PBBubbleImageView.m
//  TestOC
//
//  Created by shanbo on 2021/11/12.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBBubbleImageView.h"

@implementation PBBubbleImageView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // _bubbleView 是当前 self 的子视图
    // PBBubbleImageView 是 _bubbleView 的父视图
    if (_bubbleView) {
        if (CGRectContainsPoint(_bubbleView.frame, point)) {
            return _bubbleView;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
