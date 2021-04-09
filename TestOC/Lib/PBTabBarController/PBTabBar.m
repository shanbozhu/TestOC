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

@end
