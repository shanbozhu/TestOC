//
//  PBAnimationBubbleView.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/28.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationBubbleView.h"

@implementation PBAnimationBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 绘制矩形
    UIBezierPath *rectPath = [self bubbleRectBezierPath];
    [[UIColor bba_RGBColorFromHexString:@"#1CD350"] setFill];
    [rectPath fill];
    
    // 修改坐标系原点，旋转坐标系，方便箭头绘制
    CGPoint point = CGPointMake(130, 0);
    CGContextSaveGState(contextRef);
    CGContextTranslateCTM(contextRef, point.x, point.y);
    CGContextRotateCTM(contextRef, -[self rotateAngleOfArrow]);
    
    // 绘制箭头
    UIBezierPath *arrowPath = [self bubbleArrowBezierPathAfterContextRefCTM];
    [[UIColor bba_RGBColorFromHexString:@"#1CD350"] setFill];
    [arrowPath fill];
}

/// 绘制带有圆角的矩形
- (UIBezierPath *)bubbleRectBezierPath {
    UIBezierPath *rectPath = nil;
    CGRect _contentFrame = CGRectMake(0, 9, 160, 49);
    CGFloat _cornerRadius = 12;
    rectPath = [UIBezierPath bezierPathWithRoundedRect:_contentFrame cornerRadius:_cornerRadius];
    return rectPath;
}

/// 根据箭头方向返回箭头旋转的角度
- (CGFloat)rotateAngleOfArrow {
    return 0.0f;
}

/// 绘制气泡箭头
- (UIBezierPath *)bubbleArrowBezierPathAfterContextRefCTM {
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat arc = 2.0f;
    CGFloat _arrowWidth = 15, _arrowHeight = 9;
    // 顶部加小弧度
    [arrowPath moveToPoint:CGPointMake(-arc, arc)];
    [arrowPath addCurveToPoint:CGPointMake(arc, arc) controlPoint1:CGPointZero controlPoint2:CGPointZero];
    // 三角(高度多0.5f,解决箭头朝上有间隙case)
    [arrowPath addLineToPoint:CGPointMake(_arrowWidth/2, _arrowHeight + .5f)];
    [arrowPath addLineToPoint:CGPointMake(_arrowWidth/-2.0, _arrowHeight + .5f)];
    [arrowPath addLineToPoint:CGPointMake(-arc, arc)];
    [arrowPath closePath];
    
    return arrowPath;
}

@end
