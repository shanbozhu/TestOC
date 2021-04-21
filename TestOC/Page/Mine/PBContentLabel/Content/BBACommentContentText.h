//
//  BBACommentContentText.h
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/30.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBACommentContentLabelItem.h"

@interface BBACommentContentText : NSObject<BBACommentContentLabelTextProtocol>

/**
 当前计算约束所使用的宽度，不可更改
 */
@property (nonatomic, assign, readonly) CGFloat width;

/**
 是否可折叠
 */
@property (nonatomic, assign, readonly) BOOL foldable;

/**
 当前是否正在折叠
 注：foldable 为YES时值有效；foldabel为NO时，此值始终为NO；
 */
@property (nonatomic, assign) BOOL isUnfolded;

/**
 当前尺寸，由fable和isUnfolded共同决定；
 */
@property (nonatomic, assign, readonly) CGSize currentSize;

/**
 正常全部展示的尺寸
 */
@property (nonatomic, assign, readonly) CGSize size;

/**
 折叠之后的尺寸
 */
@property (nonatomic, assign, readonly) CGSize sizeOfFolded;


/**
 获取富文本串对应的文本约束对象（BBACommentContentText *）

 @param attributedString 要展示的富文本串
 @param width 文本展示的宽度
 @param shouldFolder 是否需要计算折行约束
 @return 文本约束对象（BBACommentContentText *）
 */
- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString width:(CGFloat)width shouldFolder:(BOOL)shouldFolder;

@end
