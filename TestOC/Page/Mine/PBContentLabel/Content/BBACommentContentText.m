//
//  BBACommentContentText.m
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/30.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BBACommentContentText.h"

#define kMaximumNumberOfLinesOfUnfold 6 //最大不折叠行数
#define kNumberOfLinesOfFolded 5 // 折叠之后的行数

@interface BBACommentContentText ()

@property (nonatomic, strong) NSAttributedString *attributedString;

@property (nonatomic, strong) NSTextStorage *textStorage;

@property (nonatomic, weak) BBACommentContentTextLayoutItem *currrentLayoutItem;

/**
 文本正常全部展示时的TextLayoutItem
 */
@property (nonatomic, strong) BBACommentContentTextLayoutItem *textLayoutItem;

/**
 文本可折叠展示时，折叠之后的TextLayoutItem
 */
@property (nonatomic, strong) BBACommentContentTextLayoutItem *textLayoutItemOfFolded;

@property (nonatomic, assign) CGFloat width;

@property(nonatomic, assign) BOOL foldable;

@end


@implementation BBACommentContentText

@synthesize attributedString = _attributedString;
@synthesize textStorage = _textStorage;
@synthesize currrentLayoutItem = _currrentLayoutItem;

- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width shouldFolder:(BOOL)shouldFolder {
    self = [super init];
    if (self) {
        self.attributedString = attributedString;
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
        BBACommentContentTextLayoutItem *layoutItem = [[BBACommentContentTextLayoutItem alloc] initWithWidth:width maximumNumberOfLines:0 forTextStorage:textStorage];
        BOOL foldable = NO;
        BBACommentContentTextLayoutItem *layoutItemOfFolded= nil;
        if (shouldFolder) {
            NSUInteger numberOfLines = [self numberOfLinesWithLayoutManager:layoutItem.layoutManager];
            if (numberOfLines > kMaximumNumberOfLinesOfUnfold) {
                layoutItemOfFolded = [[BBACommentContentTextLayoutItem alloc] initWithWidth:width
                                                                       maximumNumberOfLines:kNumberOfLinesOfFolded
                                                                             forTextStorage:textStorage];
                foldable = YES;
            }
        }
        self.width = width;
        self.textStorage = textStorage;
        self.textLayoutItem = layoutItem;
        self.textLayoutItemOfFolded = layoutItemOfFolded;
        self.foldable = foldable && (layoutItemOfFolded != nil);
        self.isUnfolded = NO;
    }
    return self;
}

- (NSUInteger)numberOfLinesWithLayoutManager:(NSLayoutManager *)layoutManager {
    NSUInteger numberOfLines, index, numberOfGlyphs = [layoutManager numberOfGlyphs];
    NSRange lineRange;
    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++){
        [layoutManager lineFragmentRectForGlyphAtIndex:index
                                        effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }
    return numberOfLines;
}


#pragma mark - Public Methods
- (CGSize)currentSize {
    return _currrentLayoutItem.size;
}

- (CGSize)size {
    return _textLayoutItem.size;
}

- (CGSize)sizeOfFolded {
    return _textLayoutItemOfFolded.size;
}

- (void)setIsUnfolded:(BOOL)isUnfolded {
    if (_foldable) {
        _isUnfolded = isUnfolded;
        if (_isUnfolded) {
            _currrentLayoutItem = _textLayoutItem;
        } else {
            _currrentLayoutItem = _textLayoutItemOfFolded;
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:self.foldButtonFrame];
             _currrentLayoutItem.textContainer.exclusionPaths = @[bezierPath];
        }
    } else {
        //不可折叠时isUnfolded始终为NO；
        _isUnfolded = NO;
        _currrentLayoutItem = _textLayoutItem;
    }
}

- (CGRect)foldButtonFrame {
    if (self.foldable && !self.isUnfolded) {
        CGSize contentSize = _textLayoutItemOfFolded.size;
        return CGRectMake(contentSize.width - 34, contentSize.height - 17, 34, 17);
    }
    return CGRectZero;
}
@end
