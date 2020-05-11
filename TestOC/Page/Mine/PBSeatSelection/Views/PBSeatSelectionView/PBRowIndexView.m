//
//  PBRowIndexView.m
//  TestOC
//
//  Created by DaMaiIOS on 17/8/11.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBRowIndexView.h"
#import "PBTestEspressosSCSLSeatInfo.h"

@implementation PBRowIndexView

+ (id)rowIndexView {
    return [[self alloc]initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor darkGrayColor]colorWithAlphaComponent:0.5];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self setNeedsDisplay];
}

- (void)setTestEspressos:(PBTestEspressos *)testEspressos {
    _testEspressos = testEspressos;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    NSDictionary *attributeName = @{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    CGFloat numberH = (self.frame.size.height - 2 * 10) / self.testEspressos.seats.count;
    
    for (int i = 0; i < self.testEspressos.seatsRowN.count; i++) {
        NSString *num = self.testEspressos.seatsRowN[i];
        
        CGSize size = [num sizeWithAttributes:attributeName];
        
        [num drawAtPoint:CGPointMake((self.frame.size.width-size.width) / 2.0, 10 + i * numberH + (numberH - size.height) / 2.0) withAttributes:attributeName];
    }
}

@end
