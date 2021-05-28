//
//  PBAnimationBubbleView.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/28.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBAnimationBubble : NSObject

@property (nonatomic, assign) CGFloat contentRadius;
@property (nonatomic, strong) UIColor *contentBackgroundColor;
@property (nonatomic, assign) CGFloat arrowWidth;
@property (nonatomic, assign) CGFloat arrowHeight;

@end

@interface PBAnimationBubbleView : UIView

@property (nonatomic, strong) PBAnimationBubble *animationBubble;

@end

NS_ASSUME_NONNULL_END
