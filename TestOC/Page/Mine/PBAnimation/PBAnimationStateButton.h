//
//  PBAnimationStateButton.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/27.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PBAnimationStateButton;
@protocol PBAnimationStateButtonDelegate <NSObject>

- (void)animationStateButtonDidTouchEndedOrCancelled:(PBAnimationStateButton *)btn;

@end

@interface PBAnimationStateButton : UIButton

@property (nonatomic, weak) id<PBAnimationStateButtonDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
