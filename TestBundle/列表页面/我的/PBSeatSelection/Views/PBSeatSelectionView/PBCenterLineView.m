//
//  PBCenterLineView.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/15.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBCenterLineView.h"

@interface PBCenterLineView ()

@property (nonatomic, weak) UIButton *centerBtn;

@end

@implementation PBCenterLineView

+ (id)centerLineView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        // centerBtn
        UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.centerBtn = centerBtn;
        [self addSubview:centerBtn];
        [centerBtn setTitle:@"看台中央" forState:UIControlStateNormal];
        [centerBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        centerBtn.titleLabel.font = [UIFont systemFontOfSize:8];
        centerBtn.layer.cornerRadius = 5;
        centerBtn.layer.masksToBounds = YES;
        centerBtn.layer.borderWidth = 0.5;
        centerBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
        centerBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // centerBtn
    self.centerBtn.frame = CGRectMake((self.frame.size.width - 50) / 2.0, -15, 50, 15);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGFloat lengths[] = {6,3};
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height);
    CGContextStrokePath(context);
}

@end
