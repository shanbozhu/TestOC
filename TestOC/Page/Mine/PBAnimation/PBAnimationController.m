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
    animationView.backgroundColor = [UIColor bba_RGBColorFromHexString:@"#1F1F1F" alpha:0.95];
    
    // image array
    UIButton *ttsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.scrollView addSubview:ttsButton];
    ttsButton.frame = CGRectMake(animationView.pb_left, animationView.pb_bottom + 20, 90, 30);
    ttsButton.backgroundColor = [UIColor bba_RGBColorFromHexString:@"#1F1F1F" alpha:0.95];
    [ttsButton setImage:[UIImage imageNamed:@"search_weather_voice_big"] forState:UIControlStateNormal];
    [ttsButton setTitle:@"听天气" forState:UIControlStateNormal];
    ttsButton.titleLabel.font = [UIFont systemFontOfSize:16];
    ttsButton.layer.borderColor = [UIColor bba_RGBColorFromHexString:@"#ffffff" alpha:0.6].CGColor;
    ttsButton.layer.borderWidth = 1.0;
    ttsButton.layer.cornerRadius = 15;
    ttsButton.layer.masksToBounds = YES;
    ttsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    ttsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
    
    ttsButton.imageView.animationDuration = 2;
    ttsButton.imageView.animationImages = [self animateImageArray];
    ttsButton.imageView.animationRepeatCount = 0;
    [ttsButton.imageView startAnimating];
    
    // image array
    UIButton *ttsButtonOne = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.scrollView addSubview:ttsButtonOne];
    ttsButtonOne.frame = CGRectMake(animationView.pb_left, ttsButton.pb_bottom + 20, 90, 30);
    ttsButtonOne.backgroundColor = [UIColor bba_RGBColorFromHexString:@"#1F1F1F" alpha:0.95];
    [ttsButtonOne setImage:[UIImage imageNamed:@"search_weather_voice_big"] forState:UIControlStateNormal];
    [ttsButtonOne setTitle:@"听天气" forState:UIControlStateNormal];
    ttsButtonOne.titleLabel.font = [UIFont systemFontOfSize:16];
    ttsButtonOne.layer.borderColor = [UIColor bba_RGBColorFromHexString:@"#ffffff" alpha:0.6].CGColor;
    ttsButtonOne.layer.borderWidth = 1.0;
    ttsButtonOne.layer.cornerRadius = 15;
    ttsButtonOne.layer.masksToBounds = YES;
    if (@available(iOS 9.0, *)) {
        ttsButtonOne.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }
    ttsButtonOne.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
    ttsButtonOne.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    
    ttsButtonOne.imageView.animationDuration = 2;
    ttsButtonOne.imageView.animationImages = [self animateImageArray];
    ttsButtonOne.imageView.animationRepeatCount = 0;
    [ttsButtonOne.imageView startAnimating];
    
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
