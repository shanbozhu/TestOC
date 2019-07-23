//
//  PBGesturePasswordView.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/9/5.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGesturePasswordView.h"
#import "PBGesturePasswordLab.h"
#import "PBGesturePasswordLockView.h"

@interface PBGesturePasswordView ()

@property (nonatomic, weak) PBGesturePasswordLab *gesturePasswordLab;

@end

@implementation PBGesturePasswordView

+ (id)gesturePasswordView {
    return [[self alloc]initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:13/255.0 green:52/255.0 blue:89/255.0 alpha:1];
        
        // 手势密码提示文字
        PBGesturePasswordLab *gesturePasswordLab = [[PBGesturePasswordLab alloc]init];
        self.gesturePasswordLab = gesturePasswordLab;
        [self addSubview:gesturePasswordLab];
        gesturePasswordLab.frame = CGRectMake(50, 100 + 15, [UIScreen mainScreen].bounds.size.width-100, 20);
        gesturePasswordLab.font = [UIFont systemFontOfSize:14];
        gesturePasswordLab.textAlignment = NSTextAlignmentCenter;
        [gesturePasswordLab showNormalMsg:@"这是提示语句"];
        
        // 手势密码解锁区域
        PBGesturePasswordLockView *gesturePasswordLockView = [PBGesturePasswordLockView gesturePasswordLockViewWithFrame:CGRectMake(50, CGRectGetMaxY(gesturePasswordLab.frame) + 50, [UIScreen mainScreen].bounds.size.width-100, [UIScreen mainScreen].bounds.size.width-100)];
        [self addSubview:gesturePasswordLockView];
    }
    return self;
}

@end
