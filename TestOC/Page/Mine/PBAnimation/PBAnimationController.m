//
//  PBAnimationController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationController.h"
#import <Lottie/LOTAnimationView.h>

#define __BAIDUTOMAS

@interface PBAnimationController ()

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation PBAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    scrollView.frame = CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - APPLICATION_NAVIGATIONBAR_HEIGHT);
    scrollView.contentSize = CGSizeMake(0, APPLICATION_FRAME_HEIGHT);
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    //
    [self addAnimationViews];
}

- (void)addAnimationViews {
    // Lottie
    NSString *lottiePath = [[NSBundle mainBundle] pathForResource:@"bubble_voicesearch" ofType:@"json"];
    LOTAnimationView *animationView = [LOTAnimationView animationWithFilePath:lottiePath];
    [self.scrollView addSubview:animationView];
    animationView.frame = CGRectMake(50, 50, 29, 48);
    animationView.loopAnimation = YES;
    [animationView play];
    animationView.backgroundColor = [UIColor blackColor];
    
    // image array
    UIButton *TTSButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.scrollView addSubview:TTSButton];
    TTSButton.frame = CGRectMake(animationView.pb_left, animationView.pb_bottom + 20, 90, 30);
    [TTSButton setImage:[UIImage imageNamed:@"search_weather_voice_big"] forState:UIControlStateNormal];
    [TTSButton setTitle:@"听天气" forState:UIControlStateNormal];
    TTSButton.titleLabel.font = [UIFont systemFontOfSize:16];
    TTSButton.layer.borderColor = [UIColor bba_RGBColorFromHexString:@"#ffffff" alpha:0.6].CGColor;
    TTSButton.layer.borderWidth = 1.0;
    TTSButton.layer.cornerRadius = 15;
    TTSButton.layer.masksToBounds = YES;
    TTSButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    TTSButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
    TTSButton.backgroundColor = [UIColor blackColor];
    
    TTSButton.imageView.animationDuration = 2;
    TTSButton.imageView.animationImages = [self animateImageArray];;
    TTSButton.imageView.animationRepeatCount = 0;
    [TTSButton.imageView startAnimating];
    
    // gif
    
    
    // video
}

- (NSMutableArray *)animateImageArray {
    NSMutableArray<UIImage *> *animateImageArray = [NSMutableArray arrayWithCapacity:25];
    for (int i = 0; i < 6; i++) {
        [animateImageArray addObject:[UIImage imageNamed:@"search_weather_voice_1_big"]];
    }
    
    for (int i = 0; i < 2; i++) {
        [animateImageArray addObject:[UIImage imageNamed:@"search_weather_voice_2_big"]];
    }
    
    [animateImageArray addObject:[UIImage imageNamed:@"search_weather_voice_3_big"]];
    [animateImageArray addObject:[UIImage imageNamed:@"search_weather_voice_4_big"]];
    
    for (int i = 0; i < 6; i++) {
        [animateImageArray addObject:[UIImage imageNamed:@"search_weather_voice_5_big"]];
    }
    
    [animateImageArray addObject:[UIImage imageNamed:@"search_weather_voice_4_big"]];
    [animateImageArray addObject:[UIImage imageNamed:@"search_weather_voice_3_big"]];
    
    for (int i = 0; i < 2; i++) {
        [animateImageArray addObject:[UIImage imageNamed:@"search_weather_voice_2_big"]];
    }
    
    for (int i = 0; i < 5; i++) {
        [animateImageArray addObject:[UIImage imageNamed:@"search_weather_voice_1_big"]];
    }
    return animateImageArray;
}

@end
