//
//  PBAnimationBubbleView.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/28.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationBubbleView.h"

@implementation PBAnimationBubble

- (instancetype)init {
    if (self = [super init]) {
        self.contentRadius = 12;
        self.arrowWidth = 15;
        self.arrowHeight = 9;
        self.contentBackgroundColor = [UIColor bba_RGBColorFromHexString:@"#1CD350"];
    }
    return self;
}

@end

@implementation PBAnimationBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAnimationBubble:(PBAnimationBubble *)animationBubble {
    _animationBubble = animationBubble;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 绘制矩形
    UIBezierPath *rectPath = [self bubbleRectBezierPath];
    [self.animationBubble.contentBackgroundColor setFill];
    [rectPath fill];
    
    // 修改坐标系原点，旋转坐标系，方便箭头绘制
    CGPoint point = CGPointMake(130, 0);
    CGContextSaveGState(contextRef);
    CGContextTranslateCTM(contextRef, point.x, point.y);
    CGContextRotateCTM(contextRef, -[self rotateAngleOfArrow]);
    
    // 绘制箭头
    UIBezierPath *arrowPath = [self bubbleArrowBezierPathAfterContextRefCTM];
    [self.animationBubble.contentBackgroundColor setFill];
    [arrowPath fill];
}

/// 绘制带有圆角的矩形
- (UIBezierPath *)bubbleRectBezierPath {
    CGRect contentFrame = CGRectMake(0, self.animationBubble.arrowHeight, self.pb_width, self.pb_height - self.animationBubble.arrowHeight);
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:contentFrame cornerRadius:self.animationBubble.contentRadius];
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
    // 顶部加小弧度
    [arrowPath moveToPoint:CGPointMake(-arc, arc)];
    [arrowPath addCurveToPoint:CGPointMake(arc, arc) controlPoint1:CGPointZero controlPoint2:CGPointZero];
    // 三角(高度多0.5f,解决箭头朝上有间隙case)
    [arrowPath addLineToPoint:CGPointMake(self.animationBubble.arrowWidth / 2, self.animationBubble.arrowHeight + .5f)];
    [arrowPath addLineToPoint:CGPointMake(self.animationBubble.arrowWidth / -2.0, self.animationBubble.arrowHeight + .5f)];
    [arrowPath addLineToPoint:CGPointMake(-arc, arc)];
    [arrowPath closePath];
    
    return arrowPath;
}

@end
