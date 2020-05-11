//
//  PBGesturePasswordCircleView.m
//  TestOC
//
//  Created by DaMaiIOS on 17/9/5.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGesturePasswordCircleView.h"

#define kPBCircleEdgeWidth 1
#define kPBTrangleLength 10

@implementation PBGesturePasswordCircleView

- (id)init {
    if ([super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat radio;
    CGRect circleRect = CGRectMake(kPBCircleEdgeWidth, kPBCircleEdgeWidth, rect.size.width - 2 * kPBCircleEdgeWidth, rect.size.height- 2 * kPBCircleEdgeWidth);
    
    if (self.circleType == CircleTypeGesture) {
        radio = 0.4;
    } else {
        radio = 1;
    }
    
    // 上下文旋转
    [self transFormCtx:ctx rect:rect];
    
    // 画空心圆
    [self drawEmptyCircleWithContext:ctx andRect:circleRect andColor:[self outCircleColor]];
    
    // 画实心圆
    [self drawSolidCircleWithContext:ctx andRect:rect andColor:[self inCircleColor] andRadio:radio];
    
    // 画三角形
    [self drawTrangleWithContext:ctx andTopPoint:CGPointMake(rect.size.width/2, 10) andLength:kPBTrangleLength andColor:[self trangleColor]];
}

- (void)transFormCtx:(CGContextRef)ctx rect:(CGRect)rect {
    CGFloat translateXY = rect.size.width * 0.5;
    CGContextTranslateCTM(ctx, translateXY, translateXY);
    CGContextRotateCTM(ctx, self.angle);
    CGContextTranslateCTM(ctx, -translateXY, -translateXY);
}

- (void)drawEmptyCircleWithContext:(CGContextRef)ctx andRect:(CGRect)rect andColor:(UIColor *)color {
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circlePath, NULL, rect);
    CGContextAddPath(ctx, circlePath);
    [color set];
    CGContextSetLineWidth(ctx, kPBCircleEdgeWidth);
    CGContextStrokePath(ctx);
    CGPathRelease(circlePath);
}

- (UIColor *)outCircleColor {
    UIColor *color;
    switch (self.circleState) {
        case CircleStateNormal:
            color = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
            break;
        case CircleStateSelected:
            color = [UIColor colorWithRed:34/255.0 green:178/255.0 blue:246/255.0 alpha:1];
            break;
        case CircleStateError:
            color = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
            break;
        case CircleStateLastOneSelected:
            color = [UIColor colorWithRed:34/255.0 green:178/255.0 blue:246/255.0 alpha:1];
            break;
        case CircleStateLastOneError:
            color = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
            break;
        default:
            color = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
            break;
    }
    return color;
}

- (void)drawSolidCircleWithContext:(CGContextRef)ctx andRect:(CGRect)rect andColor:(UIColor *)color andRadio:(CGFloat)radio {
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circlePath, NULL, CGRectMake(rect.size.width/2 * (1-radio) + kPBCircleEdgeWidth, rect.size.height/2 * (1-radio) + kPBCircleEdgeWidth, rect.size.width * radio - kPBCircleEdgeWidth * 2, rect.size.height * radio - kPBCircleEdgeWidth * 2));
    [color set];
    CGContextAddPath(ctx, circlePath);
    CGContextFillPath(ctx);
    CGPathRelease(circlePath);
}

- (UIColor *)inCircleColor {
    UIColor *color;
    switch (self.circleState) {
        case CircleStateNormal:
            color = [UIColor clearColor];
            break;
        case CircleStateSelected:
            color = [UIColor colorWithRed:34/255.0 green:178/255.0 blue:246/255.0 alpha:1];
            break;
        case CircleStateError:
            color = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
            break;
        case CircleStateLastOneSelected:
            color = [UIColor colorWithRed:34/255.0 green:178/255.0 blue:246/255.0 alpha:1];
            break;
        case CircleStateLastOneError:
            color = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
            break;
        default:
            color = [UIColor clearColor];
            break;
    }
    return color;
}

- (void)drawTrangleWithContext:(CGContextRef)ctx andTopPoint:(CGPoint)point andLength:(CGFloat)length andColor:(UIColor *)color {
    CGMutablePathRef tranglePath = CGPathCreateMutable();
    CGPathMoveToPoint(tranglePath, NULL, point.x, point.y);
    CGPathAddLineToPoint(tranglePath, NULL, point.x - length/2, point.y + length/2);
    CGPathAddLineToPoint(tranglePath, NULL, point.x + length/2, point.y + length/2);
    CGContextAddPath(ctx, tranglePath);
    [color set];
    CGContextFillPath(ctx);
    CGPathRelease(tranglePath);
}

- (UIColor *)trangleColor {
    UIColor *color;
    switch (self.circleState) {
        case CircleStateNormal:
            color = [UIColor clearColor];
            break;
        case CircleStateSelected:
            color = [UIColor colorWithRed:34/255.0 green:178/255.0 blue:246/255.0 alpha:1];
            break;
        case CircleStateError:
            color = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
            break;
        case CircleStateLastOneSelected:
            color = [UIColor clearColor];
            break;
        case CircleStateLastOneError:
            color = [UIColor clearColor];
            break;
        default:
            color = [UIColor clearColor];
            break;
    }
    return color;
}

- (void)setAngle:(CGFloat)angle {
    _angle = angle;
    [self setNeedsDisplay];
}

- (void)setCircleState:(kPBCircleState)circleState {
    _circleState = circleState;
    [self setNeedsDisplay];
}

@end
