//
//  PBTabBar.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/8.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBTabBar.h"

@implementation PBTabBar

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.exclusiveTouch = YES;
        self.frame = CGRectMake(0, APPLICATION_FRAME_HEIGHT - APPLICATION_TABBAR_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_TABBAR_HEIGHT);
        self.backgroundColor = [UIColor whiteColor];
        
        // topLineView
        UIView *topLineView = [[UIView alloc] init];
        [self addSubview:topLineView];
        topLineView.frame = CGRectMake(0, 0, APPLICATION_FRAME_WIDTH, 1.0 / [UIScreen mainScreen].scale);
        topLineView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];
    }
    return self;
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    _viewControllers = viewControllers;
    
    CGFloat buttonWidth = APPLICATION_FRAME_WIDTH / self.viewControllers.count;
    for (UIViewController *controller in self.viewControllers) {
        if ([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)controller;
            if (nav.viewControllers.count > 0) {
                UIViewController *vc = nav.viewControllers.firstObject;
                PBTabBarButton *tabBarButton = [[PBTabBarButton alloc] init];
                [self addSubview:tabBarButton];
                
                NSInteger i = 0;
                i = [self.viewControllers indexOfObject:controller];
                tabBarButton.frame = CGRectMake(i * buttonWidth, 0, buttonWidth, APPLICATION_TABBAR_CONTENT_HEIGHT);
                
                tabBarButton.buttonItem = vc.pb_tabBarButtonItem;
                
                tabBarButton.tag = i;
                [tabBarButton addTarget:self action:@selector(tabBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)tabBarButtonClick:(UIButton *)btn {
    if (self.tabBarButtonClickBlock) {
        self.tabBarButtonClickBlock(btn.tag);
    }
}

@end
