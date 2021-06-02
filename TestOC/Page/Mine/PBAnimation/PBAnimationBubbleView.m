//
//  PBAnimationBubbleView.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/28.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBAnimationBubbleView.h"

@interface PBAnimationBubbleView () {
    UITextView *_textLabel;
    NSAttributedString *_attributeText; // 气泡属性字符串
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) CGPoint arrowStartPoint;
@property (nonatomic, assign) CGPoint arrowStartPointInSelf;
@property (nonatomic, assign) CGFloat arrowWidth;
@property (nonatomic, assign) CGFloat arrowHeight;
@property (nonatomic, assign) UIEdgeInsets paddingInsets;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;

@end

@implementation PBAnimationBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _textLabel = [[UITextView alloc] init];
        _textLabel.editable = NO;
        _textLabel.scrollEnabled = NO;
        _textLabel.selectable = NO;
        _textLabel.textContainerInset = UIEdgeInsetsZero; //上下间距为0
        _textLabel.textContainer.lineFragmentPadding = 0; //左右间距为0
        _textLabel.textAlignment = NSTextAlignmentJustified;
        _textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_textLabel];
        
        self.paddingInsets = UIEdgeInsetsMake(10.f, 13.5f, 10.5f, 13.5f);
        self.cornerRadius = 12.0f;
        self.arrowWidth = 12.67f;
        self.arrowHeight = 7.0f;
        self.textFont = [UIFont systemFontOfSize:20];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)showBubbleWithText:(NSString *)text inView:(UIView *)view {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    CGRect winFrame = [view.superview convertRect:view.frame toView:window];
    CGPoint arrowStartPoint = [self arrowStartPointWithRect:winFrame];
    
    self.text = text;
    self.arrowStartPoint = arrowStartPoint;

    [self setTextLabelWithHightLightLinkKeys:@[]];
    [view addSubview:self];
    [self ba_adjustViewFrame];
}

- (CGRect)ba_adjustViewFrame {
    CGRect labelBounds = [self getTextlabelBounds];
    CGRect frame = CGRectZero;
    frame.size.width = labelBounds.size.width + [self getXDirectionExtraWidth];
    frame.size.height = labelBounds.size.height + [self getYDirectionExtraHeight];
    if (self.arrowDirection == BBABubbleViewArrowDirectionUp) {
        frame.origin.x = self.arrowStartPoint.x - frame.size.width/2;
        frame.origin.y = self.arrowStartPoint.y;
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionDown) {
        frame.origin.x = self.arrowStartPoint.x - frame.size.width/2;
        frame.origin.y = self.arrowStartPoint.y - frame.size.height;
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionLeft) {
        frame.origin.x = self.arrowStartPoint.x;
        frame.origin.y = self.arrowStartPoint.y - frame.size.height/2;
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionRight) {
        frame.origin.x = self.arrowStartPoint.x - frame.size.width;
        frame.origin.y = self.arrowStartPoint.y - frame.size.height/2;
    }
    [self adjustSubViewFrame];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    self.frame = [window convertRect:frame toView:self.superview];
    self.arrowStartPointInSelf = [self convertPoint:self.arrowStartPoint fromView:window];
    
    return frame;
}

- (void)adjustSubViewFrame {
    CGRect labelBounds = [self getTextlabelBounds];
    UIEdgeInsets contentPadding = [self contentPaddingInsets];
    CGPoint startPoint = self.arrowStartPoint;
    if (self.arrowDirection == BBABubbleViewArrowDirectionUp) {
        _textLabel.frame = CGRectMake(contentPadding.left, self.arrowHeight + contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        self.arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionDown) {
        _textLabel.frame = CGRectMake(contentPadding.left, contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        self.arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionLeft) {
        _textLabel.frame = CGRectMake(self.arrowHeight + contentPadding.left, contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        self.arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionRight) {
        _textLabel.frame = CGRectMake(contentPadding.left, contentPadding.top, labelBounds.size.width, labelBounds.size.height);
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
    CGRect realBubbleRect = CGRectMake(_textLabel.frame.origin.x - [self contentPaddingInsets].left,
                                       _textLabel.frame.origin.y - [self contentPaddingInsets].top,
                                       _textLabel.frame.size.width + [self contentPaddingInsets].left + [self contentPaddingInsets].right,
                                       _textLabel.frame.size.height + [self contentPaddingInsets].top + [self contentPaddingInsets].bottom);
    rectPath = [UIBezierPath bezierPathWithRoundedRect:realBubbleRect cornerRadius:self.cornerRadius];
    return rectPath;
}



- (CGFloat)getYDirectionExtraHeight {
    if (self.arrowDirection == BBABubbleViewArrowDirectionUp
        || self.arrowDirection == BBABubbleViewArrowDirectionDown) {
        return self.arrowHeight + [self contentPaddingInsets].top + [self contentPaddingInsets].bottom;
    }
    return [self contentPaddingInsets].top + [self contentPaddingInsets].bottom;
}

- (UIEdgeInsets)contentPaddingInsets {
    return UIEdgeInsetsMake(self.paddingInsets.top,
                            self.paddingInsets.left,
                            self.paddingInsets.bottom,
                            self.paddingInsets.right);
}

-(CGFloat)getXDirectionExtraWidth {
    if (self.arrowDirection == BBABubbleViewArrowDirectionLeft
        || self.arrowDirection == BBABubbleViewArrowDirectionRight) {
        return self.arrowHeight + [self contentPaddingInsets].left + [self contentPaddingInsets].right;
    }
    return [self contentPaddingInsets].left + [self contentPaddingInsets].right;
}

/// 显示文字的_textLabel的bounds
- (CGRect)getTextlabelBounds {
    CGSize textSize = CGSizeMake([self textLabelWidth], CGFLOAT_MAX);
    CGFloat textHeight = [self textSizeWithEstimateSize:textSize].height;
    textHeight = ceil(textHeight);
    return CGRectMake(0, 0, textSize.width, textHeight);
}

- (CGSize)textSizeWithEstimateSize:(CGSize)size {
    return [_textLabel.attributedText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

- (CGFloat)textLabelWidth {
    // 单行显示时的大小
    CGSize size = [self textSizeWithEstimateSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX)];
    CGFloat maxBubbleWidth = [self capableMaxWidthOfText];
    return MIN(ceil(size.width), ceil(maxBubbleWidth));
}

- (CGFloat)capableMaxWidthOfText {
    CGFloat capable = 0.0f;
    CGRect screen = [UIScreen mainScreen].bounds;
    if (self.arrowDirection == BBABubbleViewArrowDirectionUp || self.arrowDirection == BBABubbleViewArrowDirectionDown) {
        capable = screen.size.width - [self getXDirectionExtraWidth]; // 屏幕尺寸-额外宽度-附加视图宽度-附加视图左边距-屏幕边距
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionLeft) {
        capable = screen.size.width - self.arrowStartPoint.x - [self getXDirectionExtraWidth]; // 屏幕尺寸- 剪头X坐标-额外宽度-附加视图宽度-附加视图左边距-屏幕边距
    } else if (self.arrowDirection == BBABubbleViewArrowDirectionRight) {
        capable = self.arrowStartPoint.x - [self getXDirectionExtraWidth]; // 剪头X坐标-额外宽度-附加视图宽度-附加视图左边距-屏幕边距
    }
    return MAX(capable, 0.0f);
}


- (void)setTextLabelWithHightLightLinkKeys:(NSArray *)linkKeys {
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:self.text attributes:[self attributesOfText]];
    _textLabel.attributedText = attributeStr;
}

/// 字体的属性字典，用于计算label的大小
- (NSMutableDictionary *)attributesOfText {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = self.textFont;
    attributes[NSForegroundColorAttributeName] = self.textColor;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    return attributes;
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
