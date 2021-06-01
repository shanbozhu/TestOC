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
    UIWindow *_superWindow; //指定的父window
    CGPoint _arrowStartPointInSelf; //箭头转换后位置
    UIEdgeInsets _paddingInsets; // 文本内边距
    NSString *_text; // 气泡显示文字
    NSAttributedString *_attributeText; // 气泡属性字符串
    CGPoint _arrowStartPoint; // 箭头的指向的位置，相对于window的坐标系，否则计算出的箭头在气泡中位置不对
    CGFloat _arrowWidth; // 箭头宽度，默认为11.67
    CGFloat _arrowHeight; // 箭头高度，默认为7
}

@end

static const CGFloat kBBABubbleGuideViewToolBarheight = 20.f;

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
        
        _bubbleEdgeToScreenDistance = 10;
        _textFont = [UIFont systemFontOfSize:20];
        _paddingInsets = UIEdgeInsetsMake(10.f, 13.5f, 10.5f, 13.5f);
        _cornerRadius = 12.0f;
        _arrowWidth = 12.67f; //M4
        _arrowHeight = 7.0f; //M2
        _textColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)showBubbleWithText:(NSString *)text inView:(UIView *)view {
    // 获取window
    UIWindow *window = (view.window == nil ? [UIApplication sharedApplication].keyWindow : view.window);
    // 坐标转换
    CGRect winFrame = [view.superview convertRect:view.frame toView:window];
    // 获取箭头相对window坐标
    CGPoint arrowStartPoint = [self arrowStartPointWithRect:winFrame];
    // 转化成相对view的箭头点
    arrowStartPoint = [window convertPoint:arrowStartPoint toView:view];
    [self ba_showBubbleWithText:text attributeText:nil inView:view atPoint:arrowStartPoint hyperLinkDictionary:@{}];
}

- (void)ba_showBubbleWithText:(NSString *)text attributeText:(NSAttributedString *)attributeText inView:(UIView *)view atPoint:(CGPoint)point hyperLinkDictionary:(NSDictionary *)hyperLinkDictionary {
    // 获取window
    UIWindow *window = (view.window == nil ? [UIApplication sharedApplication].delegate.window : view.window);
    // 气泡箭头坐标
    CGPoint arrowStartPoint = [view convertPoint:point toView:window];
    // 展示、组装气泡信息
    [self ba_showBubbleWithText:text attirbuteText:attributeText superView:view window:window atPoint:arrowStartPoint hyperLinkDictionary:hyperLinkDictionary];
}

- (void)ba_showBubbleWithText:(NSString *)text
                attirbuteText:(NSAttributedString *)attributeText
                    superView:(UIView *)superView
                       window:(UIWindow *)window
                      atPoint:(CGPoint)point
          hyperLinkDictionary:(NSDictionary *)hyperLinkDictionary {
    _superWindow = window;
    // window不存在
    if (!_superWindow) {
        _superWindow = [UIApplication sharedApplication].delegate.window;
    }
    _text = text;
    _arrowStartPoint = point;

    // 设置文案
    [self setTextLabelWithHightLightLinkKeys:@[]];
    [superView addSubview:self]; // 添加视图
    [self ba_adjustViewFrame]; // 添加视图后调整坐标（坐标转换）
}

- (CGRect)ba_adjustViewFrame {
    CGRect labelBounds = [self getTextlabelBounds];
    CGRect frame = CGRectZero;
    frame.size.width = labelBounds.size.width + [self getXDirectionExtraWidth];
    frame.size.height = labelBounds.size.height + [self getYDirectionExtraHeight];
    if (_arrowDirection == BBABubbleViewArrowDirectionUp) {
        frame.origin.x = _arrowStartPoint.x - frame.size.width/2;
        frame.origin.y = _arrowStartPoint.y;
    } else if (_arrowDirection == BBABubbleViewArrowDirectionDown) {
        frame.origin.x = _arrowStartPoint.x - frame.size.width/2;
        frame.origin.y = _arrowStartPoint.y - frame.size.height;
    } else if (_arrowDirection == BBABubbleViewArrowDirectionLeft) {
        frame.origin.x = _arrowStartPoint.x;
        frame.origin.y = _arrowStartPoint.y - frame.size.height/2;
    } else if (_arrowDirection == BBABubbleViewArrowDirectionRight) {
        frame.origin.x = _arrowStartPoint.x - frame.size.width;
        frame.origin.y = _arrowStartPoint.y - frame.size.height/2;
    }
    frame = [self adjustFrame:frame]; // 调整自身frame位置
    [self adjustSubViewFrame]; // 调整子视图坐标
    self.frame = [_superWindow convertRect:frame toView:self.superview];
    _arrowStartPointInSelf = [self convertPoint:_arrowStartPoint fromView:_superWindow];
    
    return frame;
}

- (void)adjustSubViewFrame {
    CGRect labelBounds = [self getTextlabelBounds];
    UIEdgeInsets contentPadding = [self contentPaddingInsets];
    CGPoint startPoint = _arrowStartPoint;
    if (_arrowDirection == BBABubbleViewArrowDirectionUp) {
        _textLabel.frame = CGRectMake(contentPadding.left, _arrowHeight + contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        _arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    } else if (_arrowDirection == BBABubbleViewArrowDirectionDown) {
        _textLabel.frame = CGRectMake(contentPadding.left, contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        _arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    } else if (_arrowDirection == BBABubbleViewArrowDirectionLeft) {
        _textLabel.frame = CGRectMake(_arrowHeight + contentPadding.left, contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        _arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
    } else if (_arrowDirection == BBABubbleViewArrowDirectionRight) {
        _textLabel.frame = CGRectMake(contentPadding.left, contentPadding.top, labelBounds.size.width, labelBounds.size.height);
        _arrowStartPoint = CGPointMake(startPoint.x, startPoint.y);
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
    CGPoint point = _arrowStartPointInSelf;
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
    [arrowPath addLineToPoint:CGPointMake(_arrowWidth/2, _arrowHeight + .5f)];
    [arrowPath addLineToPoint:CGPointMake(_arrowWidth/-2.0, _arrowHeight + .5f)];
    [arrowPath addLineToPoint:CGPointMake(-arc, arc)];
    [arrowPath closePath];
    
    return arrowPath;
}

/// 根据箭头方向返回箭头旋转的角度
- (CGFloat)rotateAngleOfArrow {
    if (_arrowDirection == BBABubbleViewArrowDirectionUp) {
        return 0.0f;
    } else if (_arrowDirection == BBABubbleViewArrowDirectionDown) {
        return M_PI;
    } else if (_arrowDirection == BBABubbleViewArrowDirectionLeft) {
        return M_PI_2;
    } else if (_arrowDirection == BBABubbleViewArrowDirectionRight) {
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
    rectPath = [UIBezierPath bezierPathWithRoundedRect:realBubbleRect cornerRadius:_cornerRadius];
    return rectPath;
}

-(CGRect)adjustFrame:(CGRect)frame {
    CGRect screen = [UIScreen mainScreen].bounds;
    if (_arrowDirection == BBABubbleViewArrowDirectionUp
        || _arrowDirection == BBABubbleViewArrowDirectionDown) { //左右调整位置
        if (frame.size.width <= screen.size.width - 2*_bubbleEdgeToScreenDistance) {
            if (frame.origin.x < _bubbleEdgeToScreenDistance) {
                frame.origin.x = _bubbleEdgeToScreenDistance;
            }
            if (frame.origin.x + frame.size.width > screen.size.width - _bubbleEdgeToScreenDistance) {
                frame.origin.x = screen.size.width - _bubbleEdgeToScreenDistance - frame.size.width;
            }
        }
    } else if (_arrowDirection == BBABubbleViewArrowDirectionLeft
               || _arrowDirection == BBABubbleViewArrowDirectionRight) { // 上下调整位置
        if (frame.size.height <= screen.size.height - kBBABubbleGuideViewToolBarheight - 2*_bubbleEdgeToScreenDistance) {
            if (frame.origin.y < kBBABubbleGuideViewToolBarheight + _bubbleEdgeToScreenDistance) {
                frame.origin.y = kBBABubbleGuideViewToolBarheight + _bubbleEdgeToScreenDistance;
            }
            if (frame.origin.y + frame.size.height > screen.size.height - _bubbleEdgeToScreenDistance) {
                frame.origin.y = screen.size.height - _bubbleEdgeToScreenDistance - frame.size.height;
            }
        }
    }
    return frame;
}

- (CGFloat)getYDirectionExtraHeight {
    if (_arrowDirection == BBABubbleViewArrowDirectionUp
        || _arrowDirection == BBABubbleViewArrowDirectionDown) {
        return _arrowHeight + [self contentPaddingInsets].top + [self contentPaddingInsets].bottom;
    }
    return [self contentPaddingInsets].top + [self contentPaddingInsets].bottom;
}

- (UIEdgeInsets)contentPaddingInsets {
    return UIEdgeInsetsMake(_paddingInsets.top + _edgeInsets.top,
                            _paddingInsets.left + _edgeInsets.left,
                            _paddingInsets.bottom + _edgeInsets.bottom,
                            _paddingInsets.right + _edgeInsets.right);
}

-(CGFloat)getXDirectionExtraWidth {
    if (_arrowDirection == BBABubbleViewArrowDirectionLeft
        || _arrowDirection == BBABubbleViewArrowDirectionRight) {
        return _arrowHeight + [self contentPaddingInsets].left + [self contentPaddingInsets].right;
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
    if (_arrowDirection == BBABubbleViewArrowDirectionUp || _arrowDirection == BBABubbleViewArrowDirectionDown) {
        capable = screen.size.width - [self getXDirectionExtraWidth] - 2*_bubbleEdgeToScreenDistance; // 屏幕尺寸-额外宽度-附加视图宽度-附加视图左边距-屏幕边距
    } else if (_arrowDirection == BBABubbleViewArrowDirectionLeft) {
        capable = screen.size.width - _arrowStartPoint.x - [self getXDirectionExtraWidth] - _bubbleEdgeToScreenDistance; // 屏幕尺寸- 剪头X坐标-额外宽度-附加视图宽度-附加视图左边距-屏幕边距
    } else if (_arrowDirection == BBABubbleViewArrowDirectionRight) {
        capable = _arrowStartPoint.x - [self getXDirectionExtraWidth] - _bubbleEdgeToScreenDistance; // 剪头X坐标-额外宽度-附加视图宽度-附加视图左边距-屏幕边距
    }
    return MAX(capable, 0.0f);
}


- (void)setTextLabelWithHightLightLinkKeys:(NSArray *)linkKeys {
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:_text attributes:[self attributesOfText]];
    _textLabel.attributedText = attributeStr;
}

/// 字体的属性字典，用于计算label的大小
- (NSMutableDictionary *)attributesOfText {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = _textFont;
    attributes[NSForegroundColorAttributeName] = _textColor;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    return attributes;
}

/// 根据箭头方向以及给定rect，决定箭头的起始点
/// @param rect 将头指向的矩形
- (CGPoint)arrowStartPointWithRect:(CGRect)rect {
    CGFloat distoView = 3.0f;
    if (_arrowDirection == BBABubbleViewArrowDirectionUp) {
        return CGPointMake(CGRectGetMinX(rect) + rect.size.width/2, CGRectGetMaxY(rect) + distoView);
    } else if (_arrowDirection == BBABubbleViewArrowDirectionDown){
        return CGPointMake(CGRectGetMinX(rect) + rect.size.width/2, CGRectGetMinY(rect) - distoView);
    } else if (_arrowDirection == BBABubbleViewArrowDirectionLeft){
        return CGPointMake(CGRectGetMaxX(rect) + distoView, CGRectGetMinY(rect) + rect.size.height/2);
    } else if (_arrowDirection == BBABubbleViewArrowDirectionRight){
        return CGPointMake(CGRectGetMinX(rect) - distoView, CGRectGetMinY(rect) + rect.size.height/2);
    }
    return CGPointZero;
}

@end
