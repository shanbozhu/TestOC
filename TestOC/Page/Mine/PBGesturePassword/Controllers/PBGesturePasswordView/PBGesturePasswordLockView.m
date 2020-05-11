//
//  PBGesturePasswordLockView.m
//  TestOC
//
//  Created by DaMaiIOS on 17/9/6.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGesturePasswordLockView.h"
#import "PBGesturePasswordCircleView.h"

@interface PBGesturePasswordLockView ()

@property (nonatomic, strong) NSMutableArray *objs;
@property (nonatomic, strong) NSMutableArray *circleViewObjs;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign, getter=isCleanGesture) BOOL cleanGesture;

@end

#define kPBLockCircleRadius 30

@implementation PBGesturePasswordLockView

- (NSMutableArray *)objs {
    if (_objs == nil) {
        _objs = [NSMutableArray array];
    }
    return _objs;
}

- (NSMutableArray *)circleViewObjs {
    if (_circleViewObjs == nil) {
        _circleViewObjs = [NSMutableArray array];
    }
    return _circleViewObjs;
}

+ (id)gesturePasswordLockViewWithFrame:(CGRect)frame {
    return [[self alloc]initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat margin = (frame.size.width-kPBLockCircleRadius * 2 * 3) / 2;
        CGFloat circleWidth = kPBLockCircleRadius * 2;
        
        for (int i = 0; i < 9; i++) {
            PBGesturePasswordCircleView *circleView = [[PBGesturePasswordCircleView alloc]init];
            [self addSubview:circleView];
            circleView.circleType = CircleTypeGesture;
            [self.objs addObject:circleView];
            
            circleView.tag = i + 1;
            
            if (i == 0) {
                circleView.frame = CGRectMake(0, 0, circleWidth, circleWidth);
            } else {
                if (frame.size.width - CGRectGetMaxX([self.objs[i-1] frame]) >= circleWidth) {
                    circleView.frame = CGRectMake(CGRectGetMaxX([self.objs[i-1] frame]) + margin, CGRectGetMinY([self.objs[i-1] frame]), circleWidth, circleWidth);
                } else {
                    circleView.frame = CGRectMake(0, CGRectGetMaxY([self.objs[i-1] frame]) + margin, circleWidth, circleWidth);
                }
            }
        }
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"开始触摸");
    
    [self gestureEndResetMembers];
    
    self.currentPoint = CGPointZero;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self.subviews enumerateObjectsUsingBlock:^(PBGesturePasswordCircleView *circleView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(circleView.frame, point)) {
            [circleView setCircleState:CircleStateSelected];
            [self.circleViewObjs addObject:circleView];
        }
    }];
    NSLog(@"self.circleViewObjs = %@", self.circleViewObjs);
    
    [self circleViewObjsLastObjWithCircleState:CircleStateLastOneSelected];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"移动中");
    
    self.currentPoint = CGPointZero;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self.subviews enumerateObjectsUsingBlock:^(PBGesturePasswordCircleView *circleView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(circleView.frame, point)) {
            if ([self.circleViewObjs containsObject:circleView]) {
                
            } else {
                [self.circleViewObjs addObject:circleView];
                
                // 移动过程中的连线(包含跳跃连线的处理)
                [self calAngleAndconnectTheJumpedCircle];
            }
        } else {
            self.currentPoint = point;
        }
    }];
    
    [self.circleViewObjs enumerateObjectsUsingBlock:^(PBGesturePasswordCircleView *circleView, NSUInteger idx, BOOL * _Nonnull stop) {
        [circleView setCircleState:CircleStateSelected];
    }];
    
    [self circleViewObjsLastObjWithCircleState:CircleStateLastOneSelected];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"结束触摸");
    
    self.cleanGesture = NO;
    
    NSMutableString *gestureStr = [NSMutableString string];
    for (PBGesturePasswordCircleView *circleView in self.circleViewObjs) {
        [gestureStr appendFormat:@"%ld", circleView.tag];
    }
    
    CGFloat length = gestureStr.length;
    if (length == 0) {
        return;
    }
    
    // 这里将手势密码结果传出去
    NSLog(@"gestureStr = %@", gestureStr);
    
    [self errorToDisplay];
}

- (void)errorToDisplay {
    if ([self getCircleState] == CircleStateError || [self getCircleState] == CircleStateLastOneError) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self gestureEndResetMembers];
        });
    } else {
        [self gestureEndResetMembers];
    }
}

- (void)gestureEndResetMembers {
    @synchronized (self) {
        if (self.isCleanGesture == NO) {
            [self changeCircleInCircleSetWithState:CircleStateNormal];
            
            //[self.circleViewObjs removeAllObjects];
            self.circleViewObjs = nil;
            
            [self resetAllCirclesDirect];
            
            self.cleanGesture = YES;
        }
    }
}

- (void)resetAllCirclesDirect {
    [self.subviews enumerateObjectsUsingBlock:^(PBGesturePasswordCircleView *circleView, NSUInteger idx, BOOL * _Nonnull stop) {
        [circleView setAngle:0];
    }];
}

- (void)changeCircleInCircleSetWithState:(kPBCircleState)state {
    [self.circleViewObjs enumerateObjectsUsingBlock:^(PBGesturePasswordCircleView *circleView, NSUInteger idx, BOOL * _Nonnull stop) {
        [circleView setCircleState:state];
        
        if (state == CircleStateError) {
            if (idx == self.circleViewObjs.count - 1) {
                [circleView setCircleState:CircleStateLastOneError];
            }
        }
    }];
    
    [self setNeedsDisplay];
}

- (void)circleViewObjsLastObjWithCircleState:(kPBCircleState)circleState {
    [[self.circleViewObjs lastObject]setCircleState:circleState];
}

- (void)drawRect:(CGRect)rect {
    if (self.circleViewObjs.count == 0) {
        return;
    }
    
    UIColor *color;
    if ([self getCircleState] == CircleStateError) {
        color = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
    } else {
        color = [UIColor colorWithRed:34/255.0 green:178/255.0 blue:246/255.0 alpha:1];
    }
    
    [self connectCircleViewWithRect:rect andLineColor:color];
}

- (void)calAngleAndconnectTheJumpedCircle {
    if (self.circleViewObjs.count <= 1) {
        return;
    }
    
    PBGesturePasswordCircleView *lastOneCircleView = [self.circleViewObjs lastObject];
    
    PBGesturePasswordCircleView *lastTwoCircleView = self.circleViewObjs[self.circleViewObjs.count-2];
    
    CGFloat lastOneCircleViewX = lastOneCircleView.center.x;
    CGFloat lastOneCircleViewY = lastOneCircleView.center.y;
    CGFloat lastTwoCircleViewX = lastTwoCircleView.center.x;
    CGFloat lastTwoCircleViewY = lastTwoCircleView.center.y;
    
    CGFloat angle = atan2(lastOneCircleViewY - lastTwoCircleViewY, lastOneCircleViewX - lastTwoCircleViewX) + M_PI_2;
    [lastTwoCircleView setAngle:angle];
    
    CGPoint center = [self centerPointWithPointOne:lastOneCircleView.center andPointTwo:lastTwoCircleView.center];
    
    PBGesturePasswordCircleView *centerCircleView = [self enumCircleSetToFindWhichSubviewContainTheCenterPoint:center];
    
    if (centerCircleView != nil) {
        if (![self.circleViewObjs containsObject:centerCircleView]) {
            [self.circleViewObjs insertObject:centerCircleView atIndex:self.circleViewObjs.count-1];
        }
    }
}

- (PBGesturePasswordCircleView *)enumCircleSetToFindWhichSubviewContainTheCenterPoint:(CGPoint)point {
    PBGesturePasswordCircleView *centerCircleView;
    for (PBGesturePasswordCircleView *circleView in self.subviews) {
        if (CGRectContainsPoint(circleView.frame, point)) {
            centerCircleView = circleView;
        }
    }
    
    if (![self.circleViewObjs containsObject:centerCircleView]) {
        centerCircleView.angle = [self.circleViewObjs[self.circleViewObjs.count-2] angle];
    }
    
    return centerCircleView;
}

- (CGPoint)centerPointWithPointOne:(CGPoint)pointOne andPointTwo:(CGPoint)pointTwo {
    CGFloat x1 = fmax(pointOne.x, pointTwo.x);
    CGFloat x2 = fmin(pointOne.x, pointTwo.x);
    CGFloat y1 = fmax(pointOne.y, pointTwo.y);
    CGFloat y2 = fmin(pointOne.y, pointTwo.y);
    return CGPointMake((x1+x2)/2.0, (y1+y2)/2.0);
}

- (void)connectCircleViewWithRect:(CGRect)rect andLineColor:(UIColor *)color {
    // 获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 添加路径
    CGContextAddRect(ctx, rect);
    
    // 裁剪
    [self clipSubviewsWhenConnectWithContext:ctx];
    
    // 裁剪上下文
    CGContextEOClip(ctx);
    
    for (int i = 0; i < self.circleViewObjs.count; i++) {
        PBGesturePasswordCircleView *circleView = self.circleViewObjs[i];
        
        if (i == 0) {
            CGContextMoveToPoint(ctx, circleView.center.x, circleView.center.y);
        } else {
            CGContextAddLineToPoint(ctx, circleView.center.x, circleView.center.y);
        }
    }

    if (CGPointEqualToPoint(self.currentPoint, CGPointZero) == NO) {
        [self.subviews enumerateObjectsUsingBlock:^(PBGesturePasswordCircleView *circleView, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self getCircleState] == CircleStateError || [self getCircleState] == CircleStateLastOneError) {
                
            } else {
                CGContextAddLineToPoint(ctx, self.currentPoint.x, self.currentPoint.y);
            }
        }];
    }
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    CGContextSetLineWidth(ctx, 1);
    
    [color set];
    
    CGContextStrokePath(ctx);
}

- (void)clipSubviewsWhenConnectWithContext:(CGContextRef)ctx {
    [self.subviews enumerateObjectsUsingBlock:^(PBGesturePasswordCircleView *circleView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGContextAddEllipseInRect(ctx, circleView.frame);
    }];
}

- (kPBCircleState)getCircleState {
    return [[self.circleViewObjs firstObject] circleState];
}

@end
