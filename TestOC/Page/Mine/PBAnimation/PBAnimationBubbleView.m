//
//  PBAnimationBubbleView.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/28.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationBubbleView.h"

@interface PBAnimationBubbleView ()

@property (nonatomic, assign) CGPoint arrowStartPoint;
@property (nonatomic, assign) CGPoint arrowStartPointInSelf;
@property (nonatomic, assign) CGFloat arrowWidth;
@property (nonatomic, assign) CGFloat arrowHeight;
@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, weak) UITextView *textView;

@end

@implementation PBAnimationBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        UITextView *textView = [[UITextView alloc] init];
        self.textView = textView;
        textView.editable = NO;
        textView.scrollEnabled = NO;
        textView.selectable = NO;
        textView.textContainerInset = UIEdgeInsetsZero; // 上下间距为0
        textView.textContainer.lineFragmentPadding = 0; // 左右间距为0
        textView.textAlignment = NSTextAlignmentJustified;
        textView.backgroundColor = [UIColor clearColor];
        [self addSubview:textView];
        
        self.cornerRadius = 12.0f;
        self.arrowWidth = 12.67f;
        self.arrowHeight = 7.0f;
    }
    return self;
}

- (void)showBubbleWithText:(NSString *)text inView:(UIView *)view {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    CGRect winFrame = [view.superview convertRect:view.frame toView:window];
    CGPoint arrowStartPoint = [self arrowStartPointWithRect:winFrame];
    
    self.arrowStartPoint = arrowStartPoint;

    [self fillTextViewWithText:text];
    [view addSubview:self];
    [self ba_adjustViewFrame];
}

- (CGRect)ba_adjustViewFrame {
    CGRect labelBounds = [self getTextViewBounds];
    CGRect frame = CGRectZero;
    frame.size.width = labelBounds.size.width + [self getXDirectionExtraWidth];
    frame.size.height = labelBounds.size.height + [self getYDirectionExtraHeight];
    if (self.arrowDirection == BBABubbleViewArrowDirectionUp) {
        frame.origin.x = self.arrowStartPoint.x - frame.size.width / 2;
        frame.origin.y = self.arrowStartPoint.y;
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionDown) {
        frame.origin.x = self.arrowStartPoint.x - frame.size.width / 2;
        frame.origin.y = self.arrowStartPoint.y - frame.size.height;
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionLeft) {
        frame.origin.x = self.arrowStartPoint.x;
        frame.origin.y = self.arrowStartPoint.y - frame.size.height / 2;
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionRight) {
        frame.origin.x = self.arrowStartPoint.x - frame.size.width;
        frame.origin.y = self.arrowStartPoint.y - frame.size.height / 2;
    }
    [self adjustSubViewFrame];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    self.frame = [window convertRect:frame toView:self.superview];
    self.arrowStartPointInSelf = [self convertPoint:self.arrowStartPoint fromView:window];
    
    return frame;
}

- (void)adjustSubViewFrame {
    CGRect labelBounds = [self getTextViewBounds];
    UIEdgeInsets contentPadding = [self contentPaddingInsets];
    CGPoint startPoint = self.arrowStartPoint;
    if (self.arrowDirection == BBABubbleViewArrowDirectionUp) {
        self.textView.frame = CGRectMake(contentPadding.left, self.arrowHeight + contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        self.arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionDown) {
        self.textView.frame = CGRectMake(contentPadding.left, contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        self.arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionLeft) {
        self.textView.frame = CGRectMake(self.arrowHeight + contentPadding.left, contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        self.arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionRight) {
        self.textView.frame = CGRectMake(contentPadding.left, contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        self.arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    }
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    //绘制矩形
    UIBezierPath *rectPath = [self bubbleRectBezierPath];
    [self.bubbleBackgroundColor setFill];
    [rectPath fill];
    
    //修改坐标系原点，旋转坐标系，方便箭头绘制
    CGPoint point = self.arrowStartPointInSelf;
    CGContextSaveGState(contextRef);
    CGContextTranslateCTM(contextRef, point.x, point.y);
    CGContextRotateCTM(contextRef, -[self rotateAngleOfArrow]);
    
    //绘制箭头
    UIBezierPath *arrowPath = [self bubbleArrowBezierPathAfterContextRefCTM];
    [self.bubbleBackgroundColor setFill];
    [arrowPath fill];
}

/// 绘制气泡箭头
- (UIBezierPath *)bubbleArrowBezierPathAfterContextRefCTM {
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat arc = 2.0f;
    // 顶部加小弧度
    [arrowPath moveToPoint:CGPointMake(-arc, arc)];
    [arrowPath addCurveToPoint:CGPointMake(arc, arc) controlPoint1:CGPointZero controlPoint2:CGPointZero];
    // 三角(高度多0.5f,解决箭头朝上有间隙case)
    [arrowPath addLineToPoint:CGPointMake(self.arrowWidth / 2, self.arrowHeight + .5f)];
    [arrowPath addLineToPoint:CGPointMake(self.arrowWidth / -2.0, self.arrowHeight + .5f)];
    [arrowPath addLineToPoint:CGPointMake(-arc, arc)];
    [arrowPath closePath];
    
    return arrowPath;
}

/// 根据箭头方向返回箭头旋转的角度
- (CGFloat)rotateAngleOfArrow {
    if (self.arrowDirection == BBABubbleViewArrowDirectionUp) {
        return 0.0f;
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionDown) {
        return M_PI;
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionLeft) {
        return M_PI_2;
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionRight) {
        return 1.5*M_PI;
    }
    return 0.0f;
}

- (UIBezierPath *)bubbleRectBezierPath {
    UIBezierPath *rectPath = nil;
    CGRect realBubbleRect = CGRectMake(self.textView.frame.origin.x - [self contentPaddingInsets].left,
                                       self.textView.frame.origin.y - [self contentPaddingInsets].top,
                                       self.textView.frame.size.width + [self contentPaddingInsets].left + [self contentPaddingInsets].right,
                                       self.textView.frame.size.height + [self contentPaddingInsets].top + [self contentPaddingInsets].bottom);
    rectPath = [UIBezierPath bezierPathWithRoundedRect:realBubbleRect cornerRadius:self.cornerRadius];
    return rectPath;
}

- (CGFloat)getYDirectionExtraHeight {
    if (self.arrowDirection == BBABubbleViewArrowDirectionUp || self.arrowDirection == BBABubbleViewArrowDirectionDown) {
        return self.arrowHeight + [self contentPaddingInsets].top + [self contentPaddingInsets].bottom;
    }
    return [self contentPaddingInsets].top + [self contentPaddingInsets].bottom;
}

- (UIEdgeInsets)contentPaddingInsets {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)getXDirectionExtraWidth {
    if (self.arrowDirection == BBABubbleViewArrowDirectionLeft || self.arrowDirection == BBABubbleViewArrowDirectionRight) {
        return self.arrowHeight + [self contentPaddingInsets].left + [self contentPaddingInsets].right;
    }
    return [self contentPaddingInsets].left + [self contentPaddingInsets].right;
}

- (CGRect)getTextViewBounds {
    self.textView.frame = CGRectMake(0, 0, 100, CGFLOAT_MAX);
    [self.textView sizeToFit];
    return CGRectMake(0, 0, self.textView.frame.size.width, self.textView.frame.size.height);
}

- (CGSize)textSizeWithEstimateSize:(CGSize)size {
    return [self.textView.attributedText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

- (void)fillTextViewWithText:(NSString *)text {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    self.textView.attributedText = attributeStr;
}

- (CGPoint)arrowStartPointWithRect:(CGRect)rect {
    CGFloat distoView = 3.0f;
    if (self.arrowDirection == BBABubbleViewArrowDirectionUp) {
        return CGPointMake(CGRectGetMinX(rect) + rect.size.width / 2, CGRectGetMaxY(rect) + distoView);
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionDown) {
        return CGPointMake(CGRectGetMinX(rect) + rect.size.width / 2, CGRectGetMinY(rect) - distoView);
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionLeft) {
        return CGPointMake(CGRectGetMaxX(rect) + distoView, CGRectGetMinY(rect) + rect.size.height / 2);
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionRight) {
        return CGPointMake(CGRectGetMinX(rect) - distoView, CGRectGetMinY(rect) + rect.size.height / 2);
    }
    return CGPointZero;
}

@end
