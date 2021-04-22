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

/**
 要展示的富文本
 */
@property (nonatomic, strong, readonly) NSAttributedString *attributedString;

/**
 富文本对应的textStorage
 */
@property (nonatomic, strong, readonly) NSTextStorage *textStorage;

/**
 当前要展示的约束对象 @see BBACommentContentTextLayoutItem
 如有变动一定要主动调用文本视图的setNeedDisplay方法；
 */
@property (nonatomic, weak, readonly) BBACommentContentTextLayoutItem *currrentLayoutItem;

@end


/**
 提供默认的实现BBACommentContentLabelTextProtocol协议的文本内容约束对象；
 */
@interface BBACommentContentLabelItem : NSObject <BBACommentContentLabelTextProtocol>

+ (instancetype)itemWithAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width maximumNumberOfLines:(NSInteger)maximumNumberOfLines;

@end


/**
 富文本对应约束计算及储存对象；
 */
@interface BBACommentContentTextLayoutItem : NSObject

/**
 文本要展示的宽度，由初始化时传入；
 */
@property (nonatomic, assign, readonly) CGFloat width;

/**
 文本展示最大行数，在初始化时传入；
 */
@property (nonatomic, assign, readonly) NSInteger maximumNumberOfLines;

/**
 文本对应的NSTextStorage对象,在初始化时传入；
 */
@property (nonatomic, strong, readonly) NSTextStorage *textStroage;

/**
 文本对应的NSLayoutManager对象，内部创建并add到 @see textStorage中；
 */
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;

/**
 文本对应的textContainer对象，内部创建并add到 @seelayoutManager中；
 */
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

/**
 文本展示的尺寸，由textStorage、width 和 maximumNumberOfLines 三个条件计算所得；
 */
@property (nonatomic, assign, readonly) CGSize size;

/// 禁用默认初始化方法
- (instancetype)init NS_UNAVAILABLE;


- (instancetype)initWithWidth:(CGFloat)width maximumNumberOfLines:(NSInteger)maximumNumberOfLines forTextStorage:(NSTextStorage *)textStorage;

@end
