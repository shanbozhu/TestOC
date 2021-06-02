//
//  PBAnimationController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationController.h"
#import <Lottie/LOTAnimationView.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <YYImage/YYImage.h>
#import "PBAnimationStateButton.h"
#import "PBAnimationBubbleView.h"

#define kPBBackgroundColor [UIColor bba_RGBColorFromHexString:@"#1F1F1F" alpha:0.95]

@interface PBAnimationController () <PBAnimationStateButtonDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *stepRightImageView;
@property (nonatomic, weak) UILabel *stepRightLab;

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
    scrollView.delaysContentTouches = NO;
    scrollView.canCancelContentTouches = YES;
    
    //
    [self addAnimationViews];
    
    //
    [self addClickStatusViews];
    
    //
    [self addBubbleViews];
}

- (void)addAnimationViews {
    // Lottie
    NSString *lottiePath = [[NSBundle mainBundle] pathForResource:@"bubble_voicesearch" ofType:@"json"];
    LOTAnimationView *animationView = [LOTAnimationView animationWithFilePath:lottiePath];
    [self.scrollView addSubview:animationView];
    animationView.frame = CGRectMake(50, 50, 29, 48);
    animationView.loopAnimation = YES;
    [animationView play];
    animationView.backgroundColor = kPBBackgroundColor;
    
    // image array
    UIButton *ttsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.scrollView addSubview:ttsButton];
    ttsButton.frame = CGRectMake(animationView.pb_left, animationView.pb_bottom + 20, 90, 30);
    ttsButton.backgroundColor = kPBBackgroundColor;
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
    ttsButtonOne.backgroundColor = kPBBackgroundColor;
    [ttsButtonOne setImage:[UIImage imageNamed:@"search_weather_voice_big"] forState:UIControlStateNormal];
    [ttsButtonOne setTitle:@"听天气" forState:UIControlStateNormal];
    ttsButtonOne.titleLabel.font = [UIFont systemFontOfSize:16];
    ttsButtonOne.layer.borderColor = [UIColor bba_RGBColorFromHexString:@"#ffffff" alpha:0.6].CGColor;
    ttsButtonOne.layer.borderWidth = 1.0;
    ttsButtonOne.layer.cornerRadius = 15;
    ttsButtonOne.layer.masksToBounds = YES;
    if (@available(iOS 9.0, *)) {
        ttsButtonOne.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft; // 左文右图
    }
    ttsButtonOne.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
    ttsButtonOne.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    
    ttsButtonOne.imageView.animationDuration = 2;
    ttsButtonOne.imageView.animationImages = [self animateImageArray];
    ttsButtonOne.imageView.animationRepeatCount = 0;
    [ttsButtonOne.imageView startAnimating];
    
    // gif
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"commentgif_liked" ofType:@"gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:gifPath];
    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
    FLAnimatedImageView *animationImageView = [[FLAnimatedImageView alloc] init];
    [self.scrollView addSubview:animationImageView];
    animationImageView.frame = CGRectMake(animationView.pb_left, ttsButtonOne.pb_bottom + 20, 50, 50);
    animationImageView.animatedImage = animatedImage;
    animationImageView.backgroundColor = kPBBackgroundColor;
    
    // gif
    YYImage *animatedImageOne = [YYImage imageWithData:gifData];
    YYAnimatedImageView *animationImageViewOne = [[YYAnimatedImageView alloc] init];
    [self.scrollView addSubview:animationImageViewOne];
    animationImageViewOne.frame = CGRectMake(animationView.pb_left, animationImageView.pb_bottom + 20, 50, 50);
    animationImageViewOne.image = animatedImageOne;
    animationImageViewOne.backgroundColor = kPBBackgroundColor;
    
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

- (void)addClickStatusViews {
    PBAnimationStateButton *stepRightBtn = [PBAnimationStateButton buttonWithType:UIButtonTypeCustom];
    [self.scrollView addSubview:stepRightBtn];
    stepRightBtn.frame = CGRectMake(200, 50, 100, 0);
    [stepRightBtn addTarget:self
                     action:@selector(shareBtnClick:)
           forControlEvents:UIControlEventTouchUpInside];
    [stepRightBtn addTarget:self
                     action:@selector(changeToAssignAlpha:)
           forControlEvents:UIControlEventTouchDown];
    stepRightBtn.delegate = self;
    stepRightBtn.backgroundColor = kPBBackgroundColor;
    
    UIImageView *stepRightImageView = [[UIImageView alloc] init];
    self.stepRightImageView = stepRightImageView;
    [stepRightBtn addSubview:stepRightImageView];
    stepRightImageView.frame = CGRectMake((stepRightBtn.pb_width - 58) / 2.0, 0, 58, 58);
    stepRightImageView.layer.cornerRadius = 29;
    stepRightImageView.layer.masksToBounds = YES;
    stepRightImageView.image = [UIImage imageNamed:@"tomas_tts_invite_share_haoyou"];
    
    UILabel *stepRightLab = [[UILabel alloc] init];
    self.stepRightLab = stepRightLab;
    [stepRightBtn addSubview:stepRightLab];
    stepRightLab.frame = CGRectMake(0, stepRightImageView.pb_bottom + 10, stepRightBtn.pb_width, 20);
    stepRightLab.numberOfLines = 0;
    stepRightLab.textAlignment = NSTextAlignmentCenter;
    stepRightLab.font = [UIFont boldSystemFontOfSize:20];
    stepRightLab.textColor = [UIColor whiteColor];
    stepRightLab.text = @"微信好友";
    
    stepRightBtn.pb_height = stepRightLab.pb_bottom;
}

- (void)changeToAssignAlpha:(UIButton *)btn {
    self.stepRightImageView.alpha = 0.3;
    self.stepRightLab.alpha = 0.3;
    NSLog(@"haha");
}

- (void)shareBtnClick:(UIButton *)btn {
    NSLog(@"share");
}

- (void)animationStateButtonDidTouchEndedOrCancelled:(PBAnimationStateButton *)btn {
    self.stepRightImageView.alpha = 1;
    self.stepRightLab.alpha = 1;
    NSLog(@"gaga");
}

- (void)addBubbleViews {
    UIColor *color = [UIColor bba_RGBColorFromHexString:@"#1CD350"];
    UIView *hostView = [[UIView alloc] init];
    [self.scrollView addSubview:hostView];
    hostView.frame = CGRectMake(200, 160, 50, 50);
    hostView.backgroundColor = color;
    
    PBAnimationBubbleView *bubbleView = [[PBAnimationBubbleView alloc] init];
    bubbleView.arrowDirection = BBABubbleViewArrowDirectionUp;
//    bubbleView.arrowDirection = BBABubbleViewArrowDirectionRight;
    bubbleView.bubbleBackgroundColor = color;
    [bubbleView showBubbleWithText:@"自拍测福气"
                            inView:hostView];
    bubbleView.backgroundColor = kPBBackgroundColor;
}

@end
