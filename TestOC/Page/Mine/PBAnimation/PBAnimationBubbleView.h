//
//  PBAnimationBubbleView.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/28.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BBABubbleViewArrowDirection) {
    BBABubbleViewArrowDirectionUp,
    BBABubbleViewArrowDirectionDown,
    BBABubbleViewArrowDirectionLeft,
    BBABubbleViewArrowDirectionRight,
};

@interface PBAnimationBubbleView : UIView

@property (nonatomic, assign) BBABubbleViewArrowDirection arrowDirection;
@property (nonatomic, strong) UIColor *bubbleBackgroundColor;

- (void)showBubbleWithText:(NSString *)text
                    inView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
