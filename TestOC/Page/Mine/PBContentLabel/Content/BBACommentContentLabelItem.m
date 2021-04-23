//
//  BBACommentContentLabelItem.m
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/30.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BBACommentContentLabelItem.h"

@interface BBACommentContentLabelItem ()

@property (nonatomic, strong) BBACommentContentTextLayoutItem *layoutItem;

@end

@implementation BBACommentContentLabelItem

+ (instancetype)itemWithAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width maximumNumberOfLines:(NSInteger)maximumNumberOfLines {
    BBACommentContentLabelItem *item = [[self alloc] init];
    
    BBACommentContentTextLayoutItem *layoutItem = [[BBACommentContentTextLayoutItem alloc] initWithWidth:width maximumNumberOfLines:maximumNumberOfLines attributedString:attributedString];
    item.layoutItem = layoutItem;
    return item;
}

@end

#pragma mark -
@implementation BBACommentContentTextLayoutItem

- (instancetype)initWithWidth:(CGFloat)width maximumNumberOfLines:(NSInteger)maximumNumberOfLines attributedString:(NSAttributedString *)attributedString {
    if (self = [super init]) {
        _width = width;
        
        // textStorage
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
        
        // layoutManager
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [textStorage addLayoutManager:layoutManager];
        
        // textContainer
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX)];
        [layoutManager addTextContainer:textContainer];
        
        textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        textContainer.lineFragmentPadding = 0;
        textContainer.maximumNumberOfLines = maximumNumberOfLines;
        
        [layoutManager glyphRangeForTextContainer:textContainer];
        CGSize allSize =  [layoutManager usedRectForTextContainer:textContainer].size;
        
        self.textStorage = textStorage;
        self.layoutManager = layoutManager;
        self.textContainer = textContainer;
        self.size = CGSizeMake(ceil(allSize.width), ceil(allSize.height));
    }
    return self;
}

@end
