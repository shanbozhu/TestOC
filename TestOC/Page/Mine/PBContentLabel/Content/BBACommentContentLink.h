//
//  BBACommentContentLink.h
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/29.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BBACommentContentLinkType) {
    BBACommentContentLinkTypeAt = 1,          // 用户
    BBACommentContentLinkTypeTopic = 2,       // 话题
    BBACommentContentLinkTypeLink = 3,        // 网页链接
    BBACommentContentLinkTypeLookImage = 4    // 查看图片
};

FOUNDATION_EXPORT  NSString *const BBACommentContentLinkTextAttributeName;

@interface BBACommentContentLinkAttribute : NSObject


@end

@interface BBACommentContentLink : NSObject

/**
 链接类型：话题 2：链接 3：用户
 */
@property (nonatomic, assign) BBACommentContentLinkType linkType;

/**
 链接描述信息
 */
@property (nonatomic, strong) BBACommentContentLinkAttribute *linkAttribute;

/**
 链接在整个字符串中的range
 */
@property (nonatomic, assign) NSRange range;

/**
 链接文本字符在label中的区域
 */
@property (nonatomic, strong) NSArray *rects;

/**
 点击高亮态 链接文本字体颜色, Defalut is nil;
 */
@property (nonatomic, strong) UIColor *highlightedTextColor;

/**
 点击高亮态链接文本背景颜色, Defalut is nil;
 */
@property (nonatomic, strong) UIColor *highlightedBackgourndColor;

@end
