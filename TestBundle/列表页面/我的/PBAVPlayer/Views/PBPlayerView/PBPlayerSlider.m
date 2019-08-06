//
//  PBPlayerSlider.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/1.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBPlayerSlider.h"

@interface PBPlayerSlider ()

@property(nonatomic, assign)CGRect lastBounds;

@end

#define kPBSliderXBound 30
#define kPBSliderYBound 40

@implementation PBPlayerSlider

+(id)playerSlider {
    return [[self alloc]initWithFrame:CGRectZero];
}
-(id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        [self setThumbImage:[UIImage imageNamed:@"PBRound"] forState:UIControlStateNormal];
        [self setThumbImage:[UIImage imageNamed:@"PBRound"] forState:UIControlStateHighlighted];
    }
    return self;
}

//修改滑道的大小
-(CGRect)trackRectForBounds:(CGRect)bounds {
    [super trackRectForBounds:bounds];
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, 2);
}

//修改滑块的大小
-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 6;
    rect.size.width = rect.size.width + 12;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    self.lastBounds = result;
    return result;
}

//检查点击事件点击范围是否能够交给self处理
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //调用父类方法,找到能够处理event的view
    UIView *result = [super hitTest:point withEvent:event];
    if (result != self) {
        //如果这个view不是self,我们给self扩充一下响应范围,这里的扩充范围数据可以自己设置
        if ((point.y >= -15) && (point.y < (self.lastBounds.size.height + kPBSliderYBound)) && (point.x >= 0 && point.x < self.bounds.size.width)) {
            result = self;
        }
    }
    return result;
}

//检查点击事件的点是否在self范围内
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL result = [super pointInside:point withEvent:event];
    if (result == NO) {
        //如果这个点不在self范围内,我们给self扩充一下响应范围,这里的扩充范围数据可以自己设置
        if ((point.x >= (self.lastBounds.origin.x - kPBSliderXBound)) && (point.x <= (self.lastBounds.origin.x + self.lastBounds.size.width + kPBSliderXBound)) && (point.y >= -kPBSliderYBound) && (point.y < (self.lastBounds.size.height + kPBSliderYBound))) {
            result = YES;
        }
    }
    return result;
}

@end
