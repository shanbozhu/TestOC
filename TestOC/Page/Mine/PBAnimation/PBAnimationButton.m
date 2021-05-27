//
//  PBAnimationButton.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/27.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationButton.h"

@implementation PBAnimationButton

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self btnDidTouchEndedOrCancelled];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self btnDidTouchEndedOrCancelled];
}

- (void)btnDidTouchEndedOrCancelled {
    if ([self.delegate respondsToSelector:@selector(animationButtonDidTouchEndedOrCancelled:)]) {
        [self.delegate animationButtonDidTouchEndedOrCancelled:self];
    }
}

@end
