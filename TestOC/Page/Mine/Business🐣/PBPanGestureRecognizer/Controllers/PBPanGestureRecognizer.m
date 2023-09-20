//
//  PBPanGestureRecognizer.m
//  TestOC
//
//  Created by shanbo on 2023/9/20.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBPanGestureRecognizer.h"

@interface PBPanGestureRecognizer ()

@property (nonatomic, weak) UIView *monitorView;

@end

@implementation PBPanGestureRecognizer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // contentView
    UIView *contentView = [[UIView alloc] init];
    [self.view addSubview:contentView];
    contentView.frame = CGRectMake(50, APPLICATION_NAVIGATIONBAR_HEIGHT + 50, APPLICATION_FRAME_WIDTH - 100, APPLICATION_FRAME_HEIGHT - (50 + APPLICATION_NAVIGATIONBAR_HEIGHT + 50));
    contentView.layer.borderColor = [UIColor redColor].CGColor;
    contentView.layer.borderWidth = 1.1;
    
    // monitorView
    UIView *monitorView = [[UIView alloc] init];
    self.monitorView = monitorView;
    [contentView addSubview:monitorView];
    monitorView.frame = CGRectMake(50, 50, 100, 100);
    monitorView.backgroundColor = [UIColor redColor];
    
    // monitorView增加滑动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [monitorView addGestureRecognizer:panGesture];
}

- (void)handleSwipe:(UIPanGestureRecognizer *)gesture {
    if (self.monitorView) {
        UIView *superview = self.monitorView.superview;
        if (!superview) {
            return;
        }
        
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                NSLog(@"UIGestureRecognizerStateBegan");
            }
                break;
            case UIGestureRecognizerStateChanged: {
                NSLog(@"UIGestureRecognizerStateChanged");
                
                // 手势point
                CGPoint gesturePoint = [gesture locationInView:superview];
                NSLog(@"gesturePoint = %@", [NSValue valueWithCGPoint:gesturePoint]);
                
                // monitorView.frame
                CGRect targetFrame = CGRectMake(gesturePoint.x - self.monitorView.frame.size.width / 2.0f, gesturePoint.y - self.monitorView.frame.size.height / 2.0f, self.monitorView.frame.size.width, self.monitorView.frame.size.height);
                
                // 可滑动区域frame
                CGRect dragableFrame = [self dragableFrameOfView:self.monitorView];
                
                // 将 手势frame 限制在 可滑动区域frame
                if (CGRectGetMinX(targetFrame) < CGRectGetMinX(dragableFrame)) {
                    targetFrame.origin.x = CGRectGetMinX(dragableFrame);
                }
                if (CGRectGetMinY(targetFrame) < CGRectGetMinY(dragableFrame)) {
                    targetFrame.origin.y = CGRectGetMinY(dragableFrame);
                }
                if (CGRectGetMaxX(targetFrame) > CGRectGetMaxX(dragableFrame)) {
                    targetFrame.origin.x = CGRectGetMaxX(dragableFrame) - CGRectGetWidth(targetFrame);
                }
                if (CGRectGetMaxY(targetFrame) > CGRectGetMaxY(dragableFrame)) {
                    targetFrame.origin.y = CGRectGetMaxY(dragableFrame) - CGRectGetHeight(targetFrame);
                }
                
                // monitorView.frame
                self.monitorView.frame = targetFrame;
            }
                break;
            case UIGestureRecognizerStateEnded: {
                NSLog(@"UIGestureRecognizerStateEnded");
            }
            case UIGestureRecognizerStateCancelled: {
                NSLog(@"UIGestureRecognizerStateCancelled");
                
                // 最终停留位置frame
                CGRect finalPositionFrame = [self finalPositionRangeOfView:self.monitorView];
                
                // 手势point
                CGPoint gesturePoint = [gesture locationInView:superview];
                
                // 判断 手势 是否超过superview一半的位置
                BOOL onRight = [self isOnRightWhenDragFinish:gesturePoint.x totalWidth:superview.frame.size.width];
                
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    // monitorView.frame
                    CGRect targetFrame = self.monitorView.frame;
                    
                    // 手势 放开后 动画至位置
                    if (onRight) {
                        targetFrame.origin.x = CGRectGetMaxX(finalPositionFrame) - CGRectGetWidth(targetFrame);
                    } else {
                        targetFrame.origin.x = CGRectGetMinX(finalPositionFrame);
                    }
                    if (CGRectGetMinY(targetFrame) < CGRectGetMinY(finalPositionFrame)) {
                        targetFrame.origin.y = CGRectGetMinY(finalPositionFrame);
                    } else if (CGRectGetMaxY(targetFrame) > CGRectGetMaxY(finalPositionFrame)) {
                        targetFrame.origin.y = CGRectGetMaxY(finalPositionFrame) - CGRectGetHeight(targetFrame);
                    }
                    
                    // monitorView.frame
                    self.monitorView.frame = targetFrame;
                } completion:nil];
            }
                break;
            default: {
                NSLog(@"default");
            }
                break;
        }
    }
}

// monitorView可滑动的区域frame
- (CGRect)dragableFrameOfView:(UIView *)monitorView {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    return [self transformInsetsToFrame:inset inView:monitorView];
}

// 最终停留位置frame
- (CGRect)finalPositionRangeOfView:(UIView *)monitorView {
    UIEdgeInsets inset = UIEdgeInsetsMake(10, 25, 40, 55);
    return [self transformInsetsToFrame:inset inView:monitorView];
}

- (CGRect)transformInsetsToFrame:(UIEdgeInsets)insets inView:(UIView *)view {
    CGRect frame = view.superview.bounds;
    CGFloat width = CGRectGetWidth(frame) - insets.left - insets.right;
    CGFloat height = CGRectGetHeight(frame) - insets.top - insets.bottom;
    return CGRectMake(insets.left, insets.top, width, height);
}

- (BOOL)isOnRightWhenDragFinish:(CGFloat)finishX totalWidth:(CGFloat)totalWidth {
    BOOL onRight = NO;
    CGFloat halfCenter = totalWidth / 2.0;
    if (finishX > halfCenter) {
        onRight = YES;
    }
    return onRight;
}

@end
