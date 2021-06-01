//
//  PBAnimationBubbleView.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/28.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 气泡箭头指向的方向
typedef NS_ENUM(NSUInteger, BBABubbleViewArrowDirection) {
    /// 箭头向上
    BBABubbleViewArrowDirectionUp,
    /// 箭头向下
    BBABubbleViewArrowDirectionDown,
    /// 箭头向左
    BBABubbleViewArrowDirectionLeft,
    /// 箭头向右
    BBABubbleViewArrowDirectionRight,
    /// 上下左右自动选择, 默认
    BBABubbleViewArrowDirectionAuto,
};

@interface PBAnimationBubbleView : UIView

@property (nonatomic, assign) BBABubbleViewArrowDirection arrowDirection;
@property (nonatomic, strong) UIColor *bubbleBackgroundColor;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat bubbleEdgeToScreenDistance;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;

- (void)showBubbleWithText:(NSString *)text
                    inView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
