//
//  PBPlayerMaskView.m
//  TestOC
//
//  Created by DaMaiIOS on 17/8/1.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBPlayerMaskView.h"

@interface PBPlayerMaskView ()

@property (nonatomic, weak) UIView *topToolBarView;
@property (nonatomic, weak) UIView *bottomToolBarView;

@end

#define kPBPadding 10
#define kPBToolBarHeight 45

@implementation PBPlayerMaskView

+ (id)playerMaskViewWithFrame:(CGRect)frame {
    return [[self alloc]initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        // 顶部工具条
        UIView *topToolBarView = [[UIView alloc]init];
        self.topToolBarView = topToolBarView;
        [self addSubview:topToolBarView];
        topToolBarView.userInteractionEnabled = YES;
        topToolBarView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        topToolBarView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kPBToolBarHeight);
        
        // 返回按钮
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backBtn = backBtn;
        [topToolBarView addSubview:backBtn];
        backBtn.frame = CGRectMake(kPBPadding, kPBPadding, kPBToolBarHeight-kPBPadding*2, kPBToolBarHeight-kPBPadding*2);
        [backBtn setImage:[UIImage imageNamed:@"PBBackBtn"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"PBBackBtn"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 底部工具条
        UIView *bottomToolBarView = [[UIView alloc]init];
        [self addSubview:bottomToolBarView];
        bottomToolBarView.frame = CGRectMake(0, self.frame.size.height-kPBToolBarHeight, [UIScreen mainScreen].bounds.size.width, kPBToolBarHeight);
        bottomToolBarView.userInteractionEnabled = YES;
        bottomToolBarView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        bottomToolBarView.backgroundColor = [UIColor redColor];
        
        // 播放按钮
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playBtn = playBtn;
        [bottomToolBarView addSubview:playBtn];
        playBtn.frame = CGRectMake(10, 10, kPBToolBarHeight-10*2, kPBToolBarHeight-10*2);
        [playBtn setImage:[UIImage imageNamed:@"PBPlayBtn"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"PBPauseBtn"] forState:UIControlStateSelected];
        [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 全屏按钮
        UIButton *fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomToolBarView addSubview:fullBtn];
        fullBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-10-(kPBToolBarHeight-10*2), 10, kPBToolBarHeight-10*2, kPBToolBarHeight-10*2);
        [fullBtn setImage:[UIImage imageNamed:@"PBMaxBtn"] forState:UIControlStateNormal];
        [fullBtn setImage:[UIImage imageNamed:@"PBMinBtn"] forState:UIControlStateSelected];
        [fullBtn addTarget:self action:@selector(fullBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 当前播放时间
        UILabel *currentTimeLab = [[UILabel alloc]init];
        self.currentTimeLab = currentTimeLab;
        [bottomToolBarView addSubview:currentTimeLab];
        currentTimeLab.frame = CGRectMake(CGRectGetMaxX(playBtn.frame)+kPBPadding, 10, 35, kPBToolBarHeight-10*2);
        currentTimeLab.textColor = [UIColor whiteColor];
        currentTimeLab.font = [UIFont systemFontOfSize:12];
        currentTimeLab.text = @"00:00";
        currentTimeLab.textAlignment = NSTextAlignmentCenter;
        
        // 总播放时间
        UILabel *totalTimeLab = [[UILabel alloc]init];
        self.totalTimeLab = totalTimeLab;
        [bottomToolBarView addSubview:totalTimeLab];
        totalTimeLab.frame = CGRectMake(CGRectGetMinX(fullBtn.frame)-kPBPadding-35, 10, 35, kPBToolBarHeight-10*2);
        totalTimeLab.textColor = [UIColor whiteColor];
        totalTimeLab.font = [UIFont systemFontOfSize:12];
        totalTimeLab.text = @"00:00";
        totalTimeLab.textAlignment = NSTextAlignmentCenter;
        totalTimeLab.backgroundColor = [UIColor blueColor];
        
        // 缓冲条
        UIProgressView *progressView = [[UIProgressView alloc]init];
        self.progressView = progressView;
        [bottomToolBarView addSubview:progressView];
        progressView.frame = CGRectMake(CGRectGetMaxX(currentTimeLab.frame)+kPBPadding, (kPBToolBarHeight-2)/2.0, CGRectGetMinX(totalTimeLab.frame)-kPBPadding-(CGRectGetMaxX(currentTimeLab.frame)+kPBPadding), 2);
        
        // 进度条(滑动条)
        PBPlayerSlider *slider = [PBPlayerSlider playerSlider];
        self.slider = slider;
        [bottomToolBarView addSubview:slider];
        slider.frame = progressView.frame;
        slider.maximumTrackTintColor = [UIColor clearColor]; // 右边颜色
        [slider addTarget:self action:@selector(sliderTouchBegan:) forControlEvents:UIControlEventTouchDown]; // 开始滑动
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged]; // 滑动中
        [slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside]; // 滑动结束
        
        // 等待视图
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityIndicatorView = activityIndicatorView;
        [self addSubview:activityIndicatorView];
        activityIndicatorView.center = self.center;
        [activityIndicatorView startAnimating];
        
        // 加载失败
        UIButton *failBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.failBtn = failBtn;
        [self addSubview:failBtn];
        failBtn.frame = CGRectMake((self.frame.size.width-200)/2.0, (self.frame.size.height-40)/2.0, 200, 40);
        [failBtn setTitle:@"加载失败，点击重试" forState:UIControlStateNormal];
        [failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        failBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        failBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [failBtn addTarget:self action:@selector(failBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor {
    _progressBackgroundColor = progressBackgroundColor;
    
    self.progressView.trackTintColor = progressBackgroundColor;
}

- (void)setProgressBufferColor:(UIColor *)progressBufferColor {
    _progressBufferColor = progressBufferColor;
    
    self.progressView.progressTintColor = progressBufferColor;
}

- (void)setProgressPlayFinishColor:(UIColor *)progressPlayFinishColor {
    _progressPlayFinishColor = progressPlayFinishColor;
    
    self.slider.minimumTrackTintColor = progressPlayFinishColor; // 左边颜色
}

- (void)failBtnClick:(UIButton *)btn {
    
}

- (void)playBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    [self.delegate playerMaskView:self andPlayBtnClick:btn];
}

- (void)fullBtnClick:(UIButton *)btn {
    
}

// 开始滑动
- (void)sliderTouchBegan:(PBPlayerSlider *)slider {
    [self.delegate playerMaskView:self andSliderTouchBegan:slider];
}

// 滑动中
- (void)sliderValueChanged:(PBPlayerSlider *)slider {
    [self.delegate playerMaskView:self andSliderValueChanged:slider];
}

// 滑动结束
- (void)sliderTouchEnd:(PBPlayerSlider *)slider {
    [self.delegate playerMaskView:self andSliderTouchEnd:slider];
}

- (void)backBtnClick:(UIButton *)btn {
    
}

@end
