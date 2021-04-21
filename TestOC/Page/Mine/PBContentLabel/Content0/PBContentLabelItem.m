//
//  PBContentLabelItem.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/14.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBContentLabelItem.h"

@interface PBContentLabelItem ()

@property (nonatomic, strong) NSTextStorage *textStroage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, assign) CGSize size;

@end


@implementation PBContentLabelItem

- (instancetype)initWithWidth:(CGFloat)width maximumNumberOfLines:(NSInteger)maximumNumberOfLines attributedString:(NSAttributedString *)attributedString {
    if (self = [super init]) {

        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [textStorage addLayoutManager:layoutManager];
        
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX)];
        textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        textContainer.lineFragmentPadding = 0.f;
        textContainer.maximumNumberOfLines = maximumNumberOfLines;
        [layoutManager addTextContainer:textContainer];
        [layoutManager glyphRangeForTextContainer:textContainer];
        CGSize allSize =  [layoutManager usedRectForTextContainer:textContainer].size;
        
        self.textStroage = textStorage;
        self.layoutManager = layoutManager;
        self.textContainer = textContainer;
        self.size = CGSizeMake(ceil(allSize.width), ceil(allSize.height));
    }
    return self;
}

@end
