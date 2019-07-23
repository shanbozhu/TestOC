//
//  PBGesturePasswordLab.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/9/5.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGesturePasswordLab.h"

@implementation PBGesturePasswordLab

- (void)showNormalMsg:(NSString *)msg {
    self.text = msg;
    self.textColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
}

- (void)showHintMsg:(NSString *)msg {
    self.text = msg;
    self.textColor = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
}

- (void)showWarnMsg:(NSString *)msg {
    self.text = msg;
    self.textColor = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
    
    [self shake];
}

- (void)shake {
    CAKeyframeAnimation *kfa = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat s = 5;
    kfa.values = @[@(-s), @(0), @(s), @(0), @(-s), @(0), @(s), @(0)];
    kfa.duration = 0.3;
    kfa.repeatCount = 2;
    kfa.removedOnCompletion = YES;
    [self.layer addAnimation:kfa forKey:@"shake"];
}

@end
