//
//  PBAnimationController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationController.h"
#import <Lottie/LOTAnimationView.h>

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
}



@end
