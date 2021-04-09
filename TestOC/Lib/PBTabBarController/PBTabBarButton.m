//
//  PBTabBarButton.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/9.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBTabBarButton.h"

@interface PBTabBarButton ()

@property (nonatomic, weak) UILabel *titleLab;
@property (nonatomic, weak) UIImageView *iconImageView;

@end

@implementation PBTabBarButton

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLab = [[UILabel alloc] init];
        self.titleLab = titleLab;
        [self addSubview:titleLab];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont systemFontOfSize:14];
        
        UIImageView *iconImageView = [[UIImageView alloc] init];
        self.iconImageView = iconImageView;
        [self addSubview:iconImageView];
    }
    return self;
}

- (void)setButtonItem:(PBTabBarButtonItem *)buttonItem {
    _buttonItem = buttonItem;
    [self fillTabBarButton];
}

- (void)fillTabBarButton {
    self.iconImageView.image = [UIImage imageNamed:self.buttonItem.icon];
    self.iconImageView.frame = CGRectMake((self.frame.size.width - 20) / 2.0, 5, 20, 20);
    
    self.titleLab.text = self.buttonItem.title;
    self.titleLab.frame = CGRectMake(0, CGRectGetMaxY(self.iconImageView.frame) + 5, self.frame.size.width, 0);
    [self.titleLab sizeToFit];
    CGRect rect = self.titleLab.frame;
    rect.origin.x = (self.frame.size.width - self.titleLab.frame.size.width) / 2.0;
    self.titleLab.frame = rect;
}

@end
