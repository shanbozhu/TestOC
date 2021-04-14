//
//  PBContentLabel.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/14.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBContentLabel.h"

@interface PBContentLabel ()

@property (nonatomic, strong) NSTextStorage *textStroage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, assign) CGSize size;

@end

@implementation PBContentLabel

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.contentLabelItem) {
        NSLayoutManager *layoutManager = self.contentLabelItem.layoutManager;
        NSRange range = [layoutManager glyphRangeForTextContainer:self.contentLabelItem.textContainer];
        if (range.location != NSNotFound) {
            [layoutManager drawBackgroundForGlyphRange:range atPoint:CGPointMake(0, 0)];
            [layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
        }
    }
}

- (void)setContentLabelItem:(PBContentLabelItem *)contentLabelItem {
    _contentLabelItem = contentLabelItem;
    [self setNeedsDisplay];
}


@end
