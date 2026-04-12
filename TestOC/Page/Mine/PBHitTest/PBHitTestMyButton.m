//
//  PBHitTestMyButton.m
//  TestOC
//
//  Created by zhushanbo on 2026/3/23.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBHitTestMyButton.h"

@implementation PBHitTestMyButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

// 1. 按钮（第一响应者）未处理事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Button handled");
    // 不调用 super，事件不会继续传递
    // 按钮的 myBtnClickOn 方法不会被执行
    
//    [super touchesBegan:touches withEvent:event];
}

@end
