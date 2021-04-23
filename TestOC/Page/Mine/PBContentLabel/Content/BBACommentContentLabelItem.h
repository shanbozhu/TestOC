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

/// 要展示的富文本
@property (nonatomic, strong, readonly) NSAttributedString *attributedString;

/// 富文本对应的textStorage
@property (nonatomic, strong, readonly) NSTextStorage *textStorage;

/// 当前要展示的约束对象 @see BBACommentContentTextLayoutItem
@property (nonatomic, strong, readonly) BBACommentContentTextLayoutItem *layoutItem;

@end

@interface BBACommentContentLabelItem : NSObject <BBACommentContentLabelTextProtocol>

+ (instancetype)itemWithAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width maximumNumberOfLines:(NSInteger)maximumNumberOfLines;

@end


// 富文本对应约束计算及储存对象
@interface BBACommentContentTextLayoutItem : NSObject

/// 文本要展示的宽度，由初始化时传入
@property (nonatomic, assign, readonly) CGFloat width;

/// 文本对应的NSTextStorage对象,继承NSMutableAttributedString
@property (nonatomic, strong, readonly) NSTextStorage *textStroage;

/// 文本对应的NSLayoutManager对象,内部创建并add到textStorage
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;

/// 文本对应的NSTextContainer对象,内部创建并add到layoutManager
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

/// 文本展示的尺寸,由width、textStorage、maximumNumberOfLines三个条件计算所得
@property (nonatomic, assign, readonly) CGSize size;

- (instancetype)initWithWidth:(CGFloat)width maximumNumberOfLines:(NSInteger)maximumNumberOfLines forTextStorage:(NSTextStorage *)textStorage;

@end
