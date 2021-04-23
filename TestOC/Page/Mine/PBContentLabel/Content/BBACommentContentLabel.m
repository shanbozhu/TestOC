//
//  BBACommentContentLabel.m
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/22.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BBACommentContentLabel.h"
#import "BBACommentContentLink.h"


@interface BBACommentContentLabel ()

@property (nonatomic, strong) NSMutableArray<BBACommentContentLink *> *links;
@property (nonatomic, strong) id<BBACommentContentLabelTextProtocol>currentItem;
@property (nonatomic, strong) NSArray <UIView *>*heightedLinkBackgroundViews;

@end

@implementation BBACommentContentLabel

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    // 链接高亮背景
    if (_heightedLinkBackgroundViews) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        for (UIView *view in _heightedLinkBackgroundViews) {
            CGRect frame = view.frame;
            UIColor *color = view.backgroundColor;
            CGFloat cornerRadius = view.layer.cornerRadius;
            [self drawRectangle:frame inContext:context withCornerRadius:cornerRadius color:color];
        }
    }

    // 字符串
    if (_currentItem) {
        NSLayoutManager *layoutManager = _currentItem.layoutItem.layoutManager;
        NSRange range = [layoutManager glyphRangeForTextContainer:_currentItem.layoutItem.textContainer];
        if (range.location != NSNotFound) {
            [layoutManager drawBackgroundForGlyphRange:range atPoint:CGPointMake(0, 0)];
            [layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
        }
    }
    
}

- (void)drawRectangle:(CGRect)frame inContext:(CGContextRef)context withCornerRadius:(CGFloat)cornerRadius color:(UIColor *)color {
    CGContextMoveToPoint(context,CGRectGetMinX(frame) + cornerRadius, CGRectGetMinY(frame));  // 开始坐标右边开始
    CGContextAddArcToPoint(context, CGRectGetMaxX(frame), CGRectGetMinY(frame),  CGRectGetMaxX(frame), CGRectGetMinY(frame) + cornerRadius, cornerRadius);  // 右上角角度
    CGContextAddArcToPoint(context, CGRectGetMaxX(frame), CGRectGetMaxY(frame), CGRectGetMaxX(frame) - cornerRadius, CGRectGetMaxY(frame), cornerRadius); // 右下角角度
    CGContextAddArcToPoint(context, CGRectGetMinX(frame), CGRectGetMaxY(frame), CGRectGetMinX(frame), CGRectGetMaxY(frame) - cornerRadius, cornerRadius); // 左下角
    CGContextAddArcToPoint(context, CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetMinX(frame) + cornerRadius, CGRectGetMinY(frame), cornerRadius); // 左上角
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
}

#pragma mark - Set & Get Methods

- (void)setContentLabelItem:(id<BBACommentContentLabelTextProtocol>)contentLabelItem {
    _contentLabelItem = contentLabelItem;
    self.links = nil;
    self.heightedLinkBackgroundViews = nil;
    [self setCurrentItem:_contentLabelItem];
}

- (void)setCurrentItem:(id<BBACommentContentLabelTextProtocol>)currentItem {
    _currentItem = currentItem;
    [self setNeedsDisplay];
}



#pragma mark - link

/**
 获取当前文本中的所有link对象, lazyLoad方法

 @return link对象数组，link的显示位置已计算出来了；
 */
- (NSMutableArray *)links {
    if (!_links) {
        NSTextStorage *textStorage = _contentLabelItem.layoutItem.textStorage;
        NSLayoutManager *layoutManager = [textStorage.layoutManagers firstObject];
        NSTextContainer *textContainer = [layoutManager.textContainers firstObject];
        
        NSMutableArray *links = [NSMutableArray array];
        
        [textStorage enumerateAttribute:BBACommentContentLinkTextAttributeName inRange:NSMakeRange(0, textStorage.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            
            if (value == nil || ![value isKindOfClass:[BBACommentContentLink class]]) return;
            
            BBACommentContentLink *link = (BBACommentContentLink *)value;
            link.range = range;
            // 计算矩形框
            NSMutableArray *rects = [NSMutableArray array];
            
            //一段文本有可能分布在多行，分别计算分成多行后所有行的range构成的数组
            NSMutableArray<NSValue *> *ranges = [NSMutableArray array];
            [layoutManager enumerateLineFragmentsForGlyphRange:range
                                                    usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
                                                        NSRange newRange;
                                                        if (glyphRange.location <= range.location) { //当前行的起始位置 比 链接串起始位置 小；即：链接文本的头部在本行，链接从本行内开始；
                                                            if (NSMaxRange(glyphRange) <= NSMaxRange(range)) { //当前行的结束位置比 链接串末尾位置 小； 即：本行末尾在链接文本内部；
                                                                newRange = NSMakeRange(range.location, NSMaxRange(glyphRange) - range.location);
                                                            } else { //当前行结束位置 比 链接串末尾位置 大；即：链接文本尾部在本行，链接在本行结束；
                                                                newRange = range;
                                                            }
                                                        } else  { // //当前行的起始位置 比 链接串起始位置 大；即：本行开头在链接文本内部；
                                                            if (NSMaxRange(glyphRange) <= NSMaxRange(range)) { //当前行的结束位置比 链接串末尾位置 小； 即：本行末尾在链接文本内部；
                                                                newRange = glyphRange;
                                                            } else { //当前行结束位置 比 链接串末尾位置 大；即：链接文本尾部在本行，链接在本行结束；
                                                                newRange = NSMakeRange(glyphRange.location, NSMaxRange(range) - glyphRange.location);
                                                            }
                                                        }
                                                        [ranges addObject:[NSValue valueWithRange:newRange]];
                                                    }];
            //按照在每行的range计算对于的区域
            [ranges enumerateObjectsUsingBlock:^(NSValue *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange glyphRange = [obj rangeValue];
                [layoutManager enumerateEnclosingRectsForGlyphRange:glyphRange withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0)
                                                    inTextContainer:textContainer usingBlock:^(CGRect rect, BOOL * _Nonnull stop) {
                                                        if (rect.size.width != 0 && rect.size.height != 0) {
                                                            NSDictionary *attrs = [textStorage attributesAtIndex:glyphRange.location effectiveRange:NULL];
                                                            NSParagraphStyle *parag = attrs[NSParagraphStyleAttributeName];
                                                            if (parag) {
                                                                rect.size.height -= parag.lineSpacing;
                                                            }
                                                            [rects addObject:[NSValue valueWithCGRect:rect]];
                                                        }
                                                    }];
            }];
            link.rects = rects;
            
            [links addObject:link];
        }];
        
        [textStorage enumerateAttributesInRange:NSMakeRange(0, textStorage.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            
        }];
        [links count];
        _links = links;
    }
    return _links;
}


#pragma mark - 事件处理
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    
    // 查找点击的那个链接
    BBACommentContentLink *touchingLink = [self touchingLinkWithPoint:point];
    // 设置链接选中的背景
    [self showLinkHighlightedState:touchingLink];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    
    // 找出被点击的那个链接
    BBACommentContentLink *touchingLink = [self touchingLinkWithPoint:point];
    if (touchingLink) {
        if (_delegate && [_delegate conformsToProtocol:@protocol(BBACommentContentLabelDelegate)] && [_delegate respondsToSelector:@selector(contentLabel:linkDidClicked:)]) {
            [_delegate contentLabel:self linkDidClicked:touchingLink];
        }
    }
    
    // 相当于触摸被取消
    [self touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeAllLinkHighlightedState];
    });
}

#pragma mark - 链接背景处理

/**
 *  根据触摸点位置找出被触摸的链接
 *
 *  @param point 触摸点位置
 */
- (BBACommentContentLink *)touchingLinkWithPoint:(CGPoint)point
{
    __block BBACommentContentLink *touchingLink = nil;
    [self.links enumerateObjectsUsingBlock:^(BBACommentContentLink *link, NSUInteger idx, BOOL *stop) {
        for (NSValue *rect in link.rects) {
            // 扩大热区
            CGFloat deltaHeight = 7;
            CGRect rectValue = [rect CGRectValue];
            rectValue.size.height += deltaHeight;
            rectValue.origin.x -= deltaHeight / 2;
            if (CGRectContainsPoint(rectValue, point)) {
                touchingLink = link;
                break;
            }
        }
    }];
    return touchingLink;
}

/**
 *  显示连接点击高亮态
 *
 *  @param link 需要高亮显示的link
 */
- (void)showLinkHighlightedState:(BBACommentContentLink *)link {
    if (link.highlightedTextColor) {
        BBACommentContentTextLayoutItem *layoutItem = _contentLabelItem.layoutItem;
        BBACommentContentLabelItem *item = [BBACommentContentLabelItem itemWithAttributedString:_contentLabelItem.layoutItem.textStorage
                                                                                       maxWidth:layoutItem.width
                                                                           maximumNumberOfLines:layoutItem.textContainer.maximumNumberOfLines];
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:link.highlightedTextColor forKey:NSForegroundColorAttributeName];
        [item.layoutItem.textStorage addAttributes:attributes range:link.range];
        _currentItem = item;
        [self setNeedsDisplay];
    }
    
    if (link.highlightedBackgourndColor) {
        NSMutableArray *bgViews = [NSMutableArray array];
        for (NSValue *rectValue in link.rects) {
            CGRect rect = rectValue.CGRectValue;
            UIView *view = [[UIView alloc] initWithFrame:rect];
            view.backgroundColor = link.highlightedBackgourndColor;
            view.layer.cornerRadius = 3.f;
            [bgViews addObject:view];
        }
        self.heightedLinkBackgroundViews = bgViews;
        [self setNeedsDisplay];
    }
}

- (void)removeAllLinkHighlightedState {
    _currentItem = _contentLabelItem;
    self.heightedLinkBackgroundViews = nil;
    [self setNeedsDisplay];
}

#pragma mark -
/**
 *  这个方法会返回能够处理事件的控件
 *  这个方法可以用来拦截所有触摸事件
 *  @param point 触摸点
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self touchingLinkWithPoint:point]) {
        return self;
    }
    return nil;
}


@end
