//
//  PBAnimationButton.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/27.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PBAnimationButton;
@protocol PBAnimationButtonDelegate <NSObject>

- (void)animationButtonDidTouchEndedOrCancelled:(PBAnimationButton *)btn;

@end

@interface PBAnimationButton : UIButton

@property (nonatomic, weak) id<PBAnimationButtonDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
