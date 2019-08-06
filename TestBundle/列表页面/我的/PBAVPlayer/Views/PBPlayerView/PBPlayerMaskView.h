//
//  PBPlayerMaskView.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/1.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBPlayerSlider.h"

@class PBPlayerMaskView;
@protocol PBPlayerMaskViewDelegate <NSObject>

- (void)playerMaskView:(PBPlayerMaskView *)playerMaskView andPlayBtnClick:(UIButton *)btn;
- (void)playerMaskView:(PBPlayerMaskView *)playerMaskView andSliderTouchBegan:(PBPlayerSlider *)playerSlider;
- (void)playerMaskView:(PBPlayerMaskView *)playerMaskView andSliderValueChanged:(PBPlayerSlider *)slider;
- (void)playerMaskView:(PBPlayerMaskView *)playerMaskView andSliderTouchEnd:(PBPlayerSlider *)slider;

@end

@interface PBPlayerMaskView : UIButton

@property (nonatomic, strong) UIColor *progressBackgroundColor;
@property (nonatomic, strong) UIColor *progressBufferColor;
@property (nonatomic, strong) UIColor *progressPlayFinishColor;

@property (nonatomic, weak) UIButton *playBtn;
@property (nonatomic, weak) UIButton *failBtn;
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) PBPlayerSlider *slider;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) UILabel *currentTimeLab;
@property (nonatomic, weak) UILabel *totalTimeLab;

@property (nonatomic, weak) id<PBPlayerMaskViewDelegate>delegate;

+ (id)playerMaskViewWithFrame:(CGRect)frame;

@end
