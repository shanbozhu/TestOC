//
//  PBPlayerView.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/1.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBPlayerView.h"
#import "PBPlayerMaskView.h"
#import <AVFoundation/AVFoundation.h>
#import "PBGCDTimerManager.h"


NSString * const kPBSliderTimer = @"kPBSliderTimer"; //[播放时间]定时器
NSString * const kPBTapTimer = @"kPBTapTimer"; //[蒙层定时消失]定时器


enum PBPlayerState {
    PBPlayerStateFailed,     // 播放失败
    PBPlayerStateBuffering,  // 缓冲中
    PBPlayerStatePlaying,    // 播放中
    PBPlayerStateStopped,    // 停止播放
};
typedef enum PBPlayerState PBPlayerState;


@interface PBPlayerView ()<PBPlayerMaskViewDelegate>

@property(nonatomic, weak)AVPlayerItem *playerItem;
@property(nonatomic, weak)AVPlayer *player;
@property(nonatomic, weak)AVPlayerLayer *playerLayer;

@property(nonatomic, weak)PBPlayerMaskView *playerMaskView;
@property(nonatomic, assign)PBPlayerState state;
@property(nonatomic, assign)BOOL isUserPlay;
@property(nonatomic, assign)BOOL isBuffering;

@property(nonatomic, assign)NSInteger toolBarDisappearTime;

@end





@implementation PBPlayerView

+(id)playerViewWithFrame:(CGRect)frame {
    return [[self alloc]initWithFrame:frame];
}

-(id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor blackColor];
        
        
        //顶部蒙层
        PBPlayerMaskView *playerMaskView = [PBPlayerMaskView playerMaskViewWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.playerMaskView = playerMaskView;
        [self addSubview:playerMaskView];
        playerMaskView.delegate = self;
        playerMaskView.progressBackgroundColor = [UIColor colorWithRed:0.54118 green:0.51373 blue:0.50980 alpha:1];
        playerMaskView.progressBufferColor = [UIColor lightGrayColor];
        playerMaskView.progressPlayFinishColor = [UIColor whiteColor];
        [playerMaskView addTarget:self action:@selector(playerMaskViewClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //[播放时间]定时器
        [[PBGCDTimerManager sharedManager]gcdTimerManagerWithName:kPBSliderTimer andTimeInterval:1.0 andDelaySecs:0 andQueue:dispatch_get_main_queue() andRepeats:YES andAction:^{
            [self sliderTimer];
        }];
        [[PBGCDTimerManager sharedManager]startTimer:kPBSliderTimer];
        
        self.toolBarDisappearTime = 10;
    }
    return self;
}

-(void)destroyToolBarTimer {
    [[PBGCDTimerManager sharedManager] cancelTimerWithName:kPBTapTimer];
}

-(void)setToolBarDisappearTime:(NSInteger)toolBarDisappearTime {
    _toolBarDisappearTime = toolBarDisappearTime;
    [self destroyToolBarTimer];
    
    //定时器,工具条定时消失
    [[PBGCDTimerManager sharedManager] gcdTimerManagerWithName:kPBTapTimer andTimeInterval:toolBarDisappearTime andDelaySecs:toolBarDisappearTime andQueue:dispatch_get_main_queue() andRepeats:YES andAction:^{
        
    }];
}

-(void)playerMaskViewClick:(PBPlayerMaskView *)playerMaskView {
    
}

-(void)setUrl:(NSString *)url {
    _url = url;
    
    [self fillplayerView];
}

-(void)fillplayerView {
    
    {
        //播放
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:[NSURL URLWithString:self.url]]];
        self.playerItem = playerItem;
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        self.player = player;
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        self.playerLayer = playerLayer;
        [self.layer insertSublayer:playerLayer atIndex:0];
        playerLayer.frame = self.bounds;
        playerLayer.backgroundColor = [UIColor yellowColor].CGColor;
        //[player play];
    }
    
}

-(void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {
        return;
    }
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
    
    _playerItem = playerItem;
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(void)setState:(PBPlayerState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    
    if (state == PBPlayerStateBuffering) {
        [self.playerMaskView.activityIndicatorView startAnimating];
    } else if (state == PBPlayerStateFailed) {
        [self.playerMaskView.activityIndicatorView stopAnimating];
        self.playerMaskView.failBtn.hidden = NO;
        self.playerMaskView.playBtn.selected = NO;
    } else {
        [self.playerMaskView.activityIndicatorView stopAnimating];
        [self playVideo];
    }
}

-(void)sliderTimer {
    
    NSLog(@"self.playerItem.duration.timescale = %d", self.playerItem.duration.timescale);
    if (self.playerItem.duration.timescale != 0) {
        
        //设置进度条
        self.playerMaskView.slider.maximumValue = 1;
        self.playerMaskView.slider.value = CMTimeGetSeconds([self.playerItem currentTime]) / (self.playerItem.duration.value / self.playerItem.duration.timescale);
        
        //判断是否真正的在播放
        if (self.playerItem.isPlaybackLikelyToKeepUp && self.playerMaskView.slider.value > 0) {
            self.state = PBPlayerStatePlaying;
        }
        
        //当前时长
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([self.player currentTime]) / 60; //当前分钟
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([self.player currentTime]) % 60; //当前秒
        self.playerMaskView.currentTimeLab.text = [NSString stringWithFormat:@"%02ld:%02ld", proMin, proSec];
        
        //总时长
        NSInteger durMin = (NSInteger)self.playerItem.duration.value / self.playerItem.duration.timescale / 60; //总分钟
        NSInteger durSec = self.playerItem.duration.value / self.playerItem.duration.timescale % 60; //总秒
        self.playerMaskView.totalTimeLab.text = [NSString stringWithFormat:@"%02ld:%02ld", durMin, durSec];
    }
    
}

-(void)playVideo {
    self.isUserPlay = YES;
    self.playerMaskView.playBtn.selected = YES;
    
    
    [self.player play];
    [[PBGCDTimerManager sharedManager]resumeTimer:kPBSliderTimer];
}

-(void)pausePlay {
    self.playerMaskView.playBtn.selected = NO;
    [self.player pause];
    [[PBGCDTimerManager sharedManager]suspendTimer:kPBSliderTimer];
}


-(void)playerMaskView:(PBPlayerMaskView *)playerMaskView andPlayBtnClick:(UIButton *)btn {
    
    if (btn.selected == NO) {
        [self pausePlay]; //未选中状态是[停止和暂停播放]
    } else {
        [self playVideo]; //选中状态是[正在播放]
    }
    
    
}

-(void)playerMaskView:(PBPlayerMaskView *)playerMaskView andSliderTouchBegan:(PBPlayerSlider *)playerSlider {
    [self pausePlay];
}
-(void)playerMaskView:(PBPlayerMaskView *)playerMaskView andSliderValueChanged:(PBPlayerSlider *)slider {
    //计算出拖动的当前秒数
    CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
    CGFloat dragedSeconds = total * slider.value;
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [self.player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    NSInteger proMin = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60; //当前分钟
    NSInteger proSec = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60; //当前秒
    self.playerMaskView.currentTimeLab.text = [NSString stringWithFormat:@"%02ld:%02ld", proMin, proSec];
}
-(void)playerMaskView:(PBPlayerMaskView *)playerMaskView andSliderTouchEnd:(PBPlayerSlider *)slider {
    if (slider.value != 1) {
//        self.
    }
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingSomeSecond];
    } else {
        [self playVideo];
    }
}

-(void)bufferingSomeSecond {
    self.state = PBPlayerStateBuffering;
    self.isBuffering = YES;
    //需要先暂停一小会儿之后再播放,否则网络状态不好的时候再走,声音播放不出来
    [self pausePlay];
    //延时执行
    [self performSelector:@selector(bufferingSomeSecondEnd) withObject:@"Buffering" afterDelay:5];
}
-(void)bufferingSomeSecondEnd {
    [self playVideo];
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingSomeSecond];
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.playerMaskView.progressView setProgress:timeInterval / totalDuration animated:NO];
    }
}
//计算缓冲进度
-(NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem]loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; //获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; //计算缓冲总进度
    return result;
}

-(void)moviePlayDidEnd:(AVPlayerItem *)playerItem {
    [self pausePlay];
}














@end
