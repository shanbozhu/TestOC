//
//  PBHitTestParentView.m
//  TestOC
//
//  Created by zhushanbo on 2026/3/23.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBHitTestParentView.h"

@implementation PBHitTestParentView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Parent handled");
}

@end
