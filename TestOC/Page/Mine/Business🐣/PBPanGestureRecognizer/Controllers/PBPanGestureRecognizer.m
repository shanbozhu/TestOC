//
//  PBPanGestureRecognizer.m
//  TestOC
//
//  Created by shanbo on 2023/9/20.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBPanGestureRecognizer.h"

@interface PBPanGestureRecognizer ()

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
    [contentView addSubview:monitorView];
    monitorView.frame = CGRectMake(50, 50, 50, 50);
    monitorView.backgroundColor = [UIColor redColor];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [monitorView addGestureRecognizer:panGesture];
}

- (void)bbamatrix_addSwipeHandlerToView {
    if (self.widgetView) {
        @weakify(self);
        self.widgetView.onSwipeBlock = ^(UIPanGestureRecognizer *gesture) {
            @strongify(self);
            UIView *superview = self.widgetView.superview;
            if (!superview) {
                return;
            }
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                    break;
                case UIGestureRecognizerStateChanged: {
                    // 计算目标frame
                    CGRect dragableFrame = [self bbamatrix_getDragableFrameOfView:self.widgetView];
                    CGPoint ap = [gesture locationInView:superview];
                    CGFloat halfWidth = self.widgetView.bba_width / 2.0f;
                    CGFloat halfHeight = self.widgetView.bba_height / 2.0f;
                    CGRect targetFrame = CGRectMake(ap.x - halfWidth, ap.y - halfHeight, self.widgetView.bba_width, self.widgetView.bba_height);
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
                    self.widgetView.frame = targetFrame;
                }
                    break;
                case UIGestureRecognizerStateEnded:
                case UIGestureRecognizerStateCancelled: {
                    CGRect positionFrame = [self bbamatrix_getPositionRangeOfView:self.widgetView];
                    // 判断是否超过屏幕一半的位置
                    CGPoint ap = [gesture locationInView:superview];
                    BOOL onRight = [self bbamatrix_isOnRightWhenSwipeFinish:ap.x totalWidth:superview.frame.size.width];
                    // 放开后动画至位置
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        // 计算将要移动到的frame
                        CGRect resultFrame = self.widgetView.frame;
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
                        self.widgetView.frame = resultFrame;
                        self.monitorViewFrame = resultFrame;
                        [[NSUserDefaults standardUserDefaults] setValue:NSStringFromCGRect(self.monitorViewFrame) forKey:kBDPGrowthSystemTingshuTaskComponentMonitorLastFrame];
                    } completion:^(BOOL finished) {
                    }];
                }
                    break;
                default:
                    break;
            }
        };
    }
}

- (CGRect)bbamatrix_getDragableFrameOfView:(UIView *)monitorView {
    UIEdgeInsets inset = UIEdgeInsetsZero;
//    id<BDPGrowthSystemTingshuTaskExtensionProtocol> extension = self.bbamatrix_taskExtensionDelegate;
//    if (extension && [extension respondsToSelector:@selector(bbamatrix_taskBuoyViewDragEdgeInsets)]) {
//        inset = [extension bbamatrix_taskBuoyViewDragEdgeInsets];
//    }
    return [self bbamatrix_transformInsetsToFrame:inset inView:monitorView];
}

- (CGRect)bbamatrix_getPositionRangeOfView:(UIView *)monitorView {
    UIEdgeInsets inset = UIEdgeInsetsMake(kBBANavigationBarItemHeight() + BBA_SAFE_AREA_TOP_MARGIN + 4,
                            0,
                      TOOLBAR_HEIGHT,
                            0);
//    id<BDPGrowthSystemTingshuTaskExtensionProtocol> extension = self.bbamatrix_taskExtensionDelegate;
//    if (extension && [extension respondsToSelector:@selector(bbamatrix_taskBuoyViewPositionEdgeInsets)]) {
//        inset = [extension bbamatrix_taskBuoyViewPositionEdgeInsets];
//    }
    return [self bbamatrix_transformInsetsToFrame:inset inView:monitorView];
}

- (CGRect)bbamatrix_transformInsetsToFrame:(UIEdgeInsets)insets inView:(UIView *)view {
    CGRect frame = view.superview.bounds;
    CGFloat x = insets.left;
    CGFloat y = insets.top;
    CGFloat width = CGRectGetWidth(frame) - insets.left - insets.right;
    CGFloat height = CGRectGetHeight(frame) - insets.top - insets.bottom;
    return CGRectMake(x, y, width, height);
}

- (BOOL)bbamatrix_isOnRightWhenSwipeFinish:(CGFloat)finishX totalWidth:(CGFloat)totalWidth {
//    if ([self.bbamatrix_taskExtensionDelegate respondsToSelector:@selector(bbamatrix_buoyFixedDirection)]) {
//        BDPGrowthSystemTingshuBuoyFixedDirection direction = [self.bbamatrix_taskExtensionDelegate bbamatrix_buoyFixedDirection];
//        switch (direction) {
//            case BDPGrowthSystemTingshuBuoyFixedDirectionLeft:
//                return NO;
//            case BDPGrowthSystemTingshuBuoyFixedDirectionRight:
//                return YES;
//            default:
//                break;
//        }
//    }
    BOOL onRight = NO;
    CGFloat halfCenter = totalWidth / 2.0;
    if (finishX > halfCenter) {
        onRight = YES;
    }
    return onRight;
}



@end
