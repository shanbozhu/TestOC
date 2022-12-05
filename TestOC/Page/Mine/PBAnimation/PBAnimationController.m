//
//  PBAnimationController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationController.h"
#import <Lottie/LOTAnimationView.h>
#import <SDWebImage/SDAnimatedImageView.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <YYImage/YYImage.h>
#import "PBAnimationBubbleView.h"
#import "PBBubbleImageView.h"

#define kPBBackgroundColor [UIColor bba_RGBColorFromHexString:@"#1F1F1F" alpha:0.95]

@interface PBAnimationController ()

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation PBAnimationController

#pragma mark -

NSArray *allSubviews(UIView *aView) {
    NSArray *results = [aView subviews];
    for (UIView *eachView in aView.subviews) {
        NSArray *subviews = allSubviews(eachView);
        if (subviews)
            results = [results arrayByAddingObjectsFromArray:subviews];
    }
    return results;
}

- (UIView *)navigationBarBottomLineView {
    // 去掉系统导航栏底部分割线
    NSArray *subViews = allSubviews(self.navigationController.navigationBar);
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[UIView class]] && view.bounds.size.height > 0 && view.bounds.size.height < 1) {
            view.hidden = YES;
            return view;
        }
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self navigationBarBottomLineView].hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self navigationBarBottomLineView].hidden = NO;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    // scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    scrollView.frame = CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - APPLICATION_NAVIGATIONBAR_HEIGHT);
    scrollView.contentSize = CGSizeMake(0, APPLICATION_FRAME_HEIGHT);
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    // 动画
    [self addAnimationViews];
    
    // 气泡
    [self addBubbleViews];
    
    // 开关
    [self addSwitchView];
}

#pragma mark - 动画

- (void)addAnimationViews {
    // Lottie
    NSString *lottiePath = [[NSBundle mainBundle] pathForResource:@"bubble_voicesearch_lottie" ofType:@"json"];
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
    SDAnimatedImageView *animationImageViewTwo = [SDAnimatedImageView new];
    [self.scrollView addSubview:animationImageViewTwo];
    animationImageViewTwo.frame = CGRectMake(animationView.pb_left, animationImageView.pb_bottom + 20, 50, 50);
    SDAnimatedImage *animatedImageTwo = [SDAnimatedImage imageNamed:@"commentgif_liked.gif"];
    animationImageViewTwo.image = animatedImageTwo;
    animationImageViewTwo.shouldCustomLoopCount = YES;
    animationImageViewTwo.animationRepeatCount = CGFLOAT_MAX;
    animationImageViewTwo.backgroundColor = kPBBackgroundColor;
    
    // gif
    YYImage *animatedImageOne = [YYImage imageWithData:gifData];
    YYAnimatedImageView *animationImageViewOne = [[YYAnimatedImageView alloc] init];
    [self.scrollView addSubview:animationImageViewOne];
    animationImageViewOne.frame = CGRectMake(animationView.pb_left, animationImageViewTwo.pb_bottom + 20, 50, 50);
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

#pragma mark - 气泡

- (void)addBubbleViews {
    // 代码实现
    PBBubbleImageView *hostView = [[PBBubbleImageView alloc] init];
    [self.scrollView addSubview:hostView];
    hostView.frame = CGRectMake(200, 160, 50, 50);
    hostView.image = [UIImage imageNamed:@"tomas_tts_invite_share_haoyou"];
    
    PBAnimationBubbleView *bubbleView = [[PBAnimationBubbleView alloc] init];
    bubbleView.arrowDirection = BBABubbleViewArrowDirectionUp;
    bubbleView.bubbleClickBlock = ^{
        NSLog(@"超出父视图frame的气泡被点击了");
    };
    bubbleView.bubbleBackgroundColor = [UIColor bba_RGBColorFromHexString:@"#1CD350"];
    [bubbleView showBubbleWithText:@"自拍测福气自拍测福气" inView:hostView];
    bubbleView.backgroundColor = kPBBackgroundColor;
    
    hostView.bubbleView = bubbleView;
    
    // 图片拉伸实现
    // https://zhuanlan.zhihu.com/p/322407368
    // https://www.yotrolz.com/posts/5fe4e0ec/
    // https://www.jianshu.com/p/c9cbbdaa9b02
    // https://blog.51cto.com/u_15127644/4057466
    UIImage *image = [UIImage imageNamed:@"qipao_right_normal_blue"]; // qipao_up_normal_blue
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSLog(@"width = %lf, height = %lf", width, height); // 原始尺寸: width = 48.000000, height = 40.000000
    
    UIImageView *oneBubble = [[UIImageView alloc] init];
    [self.scrollView addSubview:oneBubble];
    oneBubble.backgroundColor = kPBBackgroundColor;
    
    oneBubble.frame = CGRectMake(200, 400, 80, 100);
    
    // iOS 5.0之前
    // 拉伸图片位置(23, 13, 1, 1)面积为1*1的矩形部分
    //oneBubble.image = [image stretchableImageWithLeftCapWidth:23 topCapHeight:13];
    
    // iOS 5.0
    //oneBubble.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 30, 20)];
    
    // iOS 6.0+
    // UIImageResizingModeTile = 0,    拉伸模式,通过拉伸UIEdgeInsets指定的矩形区域来填充图片
    // UIImageResizingModeStretch = 1, 平铺模式,通过重复显示UIEdgeInsets指定的矩形区域来填充图片
    oneBubble.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 30, 20) resizingMode:UIImageResizingModeStretch];
}

#pragma mark - 开关

- (void)addSwitchView {
    UIView *backView = [[UIView alloc] init];
    [self.scrollView addSubview:backView];
    backView.backgroundColor = [UIColor lightGrayColor];
    backView.frame = CGRectMake(200, 300, 80, 80);

    // sw
    UISwitch *sw = [[UISwitch alloc] init];
    [backView addSubview:sw];
    sw.frame = CGRectMake((backView.frame.size.width - sw.frame.size.width) / 2.0, (backView.frame.size.height - sw.frame.size.height) / 2.0, sw.frame.size.width, sw.frame.size.height); // 先使用sw.frame.size.width,在原有大小上计算居中
    sw.transform = CGAffineTransformMakeScale(0.76f, 0.73f); // 然后在长宽整体进行缩放,注意先后顺序
    sw.backgroundColor = kPBBackgroundColor;
    sw.onTintColor = [UIColor blueColor];
    sw.thumbTintColor = [UIColor redColor];
    sw.tintColor = [UIColor yellowColor];
    UIView *view = sw.subviews.firstObject;
    if ([view isKindOfClass:[UIView class]] && [view respondsToSelector:@selector(backgroundColor)]) {
        view.backgroundColor = [UIColor grayColor];
        view.layer.cornerRadius = 15.5f;
    }
}

@end
