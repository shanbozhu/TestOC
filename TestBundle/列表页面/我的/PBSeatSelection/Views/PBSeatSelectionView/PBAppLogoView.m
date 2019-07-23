//
//  PBAppLogoView.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/11.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAppLogoView.h"

@interface PBAppLogoView ()

@property (nonatomic, weak) UIImageView *appLogoImageView;

@end

@implementation PBAppLogoView

+ (id)appLogoView {
    return [[self alloc]initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        // appLogoImageView
        UIImageView *appLogoImageView = [[UIImageView alloc]init];
        self.appLogoImageView = appLogoImageView;
        [self addSubview:appLogoImageView];
        appLogoImageView.image = [UIImage imageNamed:@"maoyan_logo"];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // appLogoImageView
    self.appLogoImageView.frame = self.bounds;
}

@end
