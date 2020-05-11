//
//  PBHallLogoView.m
//  TestOC
//
//  Created by DaMaiIOS on 17/8/11.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBHallLogoView.h"

@interface PBHallLogoView ()

@property (nonatomic, weak) UIImageView *hallLogoImageView;
@property (nonatomic, weak) UILabel *hallNameLab;

@end

@implementation PBHallLogoView

+ (id)hallLogoView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        // hallLogoImageView
        UIImageView *hallLogoImageView = [[UIImageView alloc]init];
        self.hallLogoImageView = hallLogoImageView;
        [self addSubview:hallLogoImageView];
        
        // hallNameLab
        UILabel *hallNameLab = [[UILabel alloc]init];
        self.hallNameLab = hallNameLab;
        [hallLogoImageView addSubview:hallNameLab];
    }
    return self;
}

- (void)setTestEspressos:(PBTestEspressos *)testEspressos {
    _testEspressos = testEspressos;
    
    [self fillHallLogoView];
}

- (void)fillHallLogoView {
    // hallLogoImageView
    self.hallLogoImageView.image = [UIImage imageNamed:@"pbseatselection_screenBg"];
    self.hallLogoImageView.frame = self.bounds;
    
    // hallNameLab
    self.hallNameLab.frame = self.hallLogoImageView.bounds;
    self.hallNameLab.font = [UIFont systemFontOfSize:9];
    self.hallNameLab.textColor = [UIColor darkGrayColor];
    self.hallNameLab.textAlignment = NSTextAlignmentCenter;
    self.hallNameLab.text = @"测试看台";
}

@end
