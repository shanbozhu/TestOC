//
//  BBACommentContentLink.h
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/29.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT  NSString *const BBACommentContentLinkTextAttributeName;

@interface BBACommentContentLinkAttribute : NSObject


@end

@interface BBACommentContentLink : NSObject

/// 链接信息
@property (nonatomic, strong) BBACommentContentLinkAttribute *linkAttribute;

/// 链接在整个字符串中的range
@property (nonatomic, assign) NSRange range;

/// 链接文本在label中的区域
@property (nonatomic, strong) NSArray *rects;

/// 点击高亮态 链接文本字体颜色
@property (nonatomic, strong) UIColor *highlightedTextColor;

/// 点击高亮态链接文本背景颜色
@property (nonatomic, strong) UIColor *highlightedBackgourndColor;

@end
