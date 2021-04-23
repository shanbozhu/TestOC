//
//  BBACommentContentLabelItem.h
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/30.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBACommentContentTextLayoutItem;

@protocol BBACommentContentLabelTextProtocol <NSObject>

@property (nonatomic, strong, readonly) BBACommentContentTextLayoutItem *layoutItem;

@end

@interface BBACommentContentLabelItem : NSObject <BBACommentContentLabelTextProtocol>

+ (instancetype)itemWithAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth maximumNumberOfLines:(NSInteger)maximumNumberOfLines;

@end


// 富文本对应约束计算及储存对象
@interface BBACommentContentTextLayoutItem : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, assign) CGSize size;

- (instancetype)initWithMaxWidth:(CGFloat)width maximumNumberOfLines:(NSInteger)maximumNumberOfLines attributedString:(NSAttributedString *)attributedString;

@end
