//
//  PBPanGestureRecognizer.m
//  TestOC
//
//  Created by shanbo on 2023/9/20.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBPanGestureRecognizer.h"

const CGFloat kBDPGrowthSystemTingshuTaskBuoyViewVerticalMargin = 20.0f;
const CGFloat kBDPGrowthSystemTingshuTaskBuoyViewVerticalTopMargin = 43.0f;
const CGFloat kBDPGrowthSystemTingshuTaskBuoyViewHorizonMargin = 13.0f;

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
    monitorView.frame = CGRectMake(50, 50, 50, 50);
    monitorView.backgroundColor = [UIColor redColor];
    
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
                
            }
                break;
            case UIGestureRecognizerStateChanged: {
                // 计算目标frame
                CGRect dragableFrame = [self getDragableFrameOfView:self.monitorView];
                CGPoint ap = [gesture locationInView:superview];
                CGFloat halfWidth = self.monitorView.frame.size.width / 2.0f;
                CGFloat halfHeight = self.monitorView.frame.size.height / 2.0f;
                CGRect targetFrame = CGRectMake(ap.x - halfWidth, ap.y - halfHeight, self.monitorView.frame.size.width, self.monitorView.frame.size.height);
                // 修正目标frame
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
                self.monitorView.frame = targetFrame;
            }
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled: {
                CGRect positionFrame = [self getPositionRangeOfView:self.monitorView];
                // 判断是否超过屏幕一半的位置
                CGPoint ap = [gesture locationInView:superview];
                BOOL onRight = [self isOnRightWhenSwipeFinish:ap.x totalWidth:superview.frame.size.width];
                // 放开后动画至位置
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    // 计算将要移动到的frame
                    CGRect resultFrame = self.monitorView.frame;
                    // 贴边
                    if (onRight) {
                        // kBDPGrowthSystemTingshuTaskBuoyViewHorizonMargin 解释：贴边要求有固定间距
                        resultFrame.origin.x = CGRectGetMaxX(positionFrame) - CGRectGetWidth(resultFrame) - kBDPGrowthSystemTingshuTaskBuoyViewHorizonMargin;
                    } else {
                        resultFrame.origin.x = CGRectGetMinX(positionFrame) + kBDPGrowthSystemTingshuTaskBuoyViewHorizonMargin;
                    }
                    // 修正y
                    CGFloat minY = CGRectGetMinY(positionFrame) + kBDPGrowthSystemTingshuTaskBuoyViewVerticalTopMargin;
                    CGFloat maxY = CGRectGetMaxY(positionFrame) - kBDPGrowthSystemTingshuTaskBuoyViewVerticalMargin;
                    if (CGRectGetMinY(resultFrame) < minY) {
                        resultFrame.origin.y = minY;
                    } else if (CGRectGetMaxY(resultFrame) > maxY) {
                        resultFrame.origin.y = maxY - CGRectGetHeight(resultFrame);
                    }
                    self.monitorView.frame = resultFrame;
                } completion:^(BOOL finished) {
                }];
            }
                break;
            default: {
                
            }
                break;
        }
    }
}

// monitorView可拖拽的区域frame
- (CGRect)getDragableFrameOfView:(UIView *)monitorView {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    return [self transformInsetsToFrame:inset inView:monitorView];
}

- (CGRect)getPositionRangeOfView:(UIView *)monitorView {
    UIEdgeInsets inset = UIEdgeInsetsMake(APPLICATION_NAVIGATIONBAR_HEIGHT,
                                          0,
                                          APPLICATION_TABBAR_HEIGHT,
                                          0);
    return [self transformInsetsToFrame:inset inView:monitorView];
}

- (CGRect)transformInsetsToFrame:(UIEdgeInsets)insets inView:(UIView *)view {
    CGRect frame = view.superview.bounds;
    CGFloat x = insets.left;
    CGFloat y = insets.top;
    CGFloat width = CGRectGetWidth(frame) - insets.left - insets.right;
    CGFloat height = CGRectGetHeight(frame) - insets.top - insets.bottom;
    return CGRectMake(x, y, width, height);
}

- (BOOL)isOnRightWhenSwipeFinish:(CGFloat)finishX totalWidth:(CGFloat)totalWidth {
    BOOL onRight = NO;
    CGFloat halfCenter = totalWidth / 2.0;
    if (finishX > halfCenter) {
        onRight = YES;
    }
    return onRight;
}

@end
