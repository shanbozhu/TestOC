//
//  BBACommentContentLink.h
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/29.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 【10.5新增】转发同时评论，定义富文本link信息类型
typedef NS_ENUM(NSInteger, BBACommentContentLinkType) {
    BBACommentContentLinkTypeAt = 1,  // 用户
    BBACommentContentLinkTypeTopic = 2,  // 话题
    BBACommentContentLinkTypeLink = 3,  // 网页链接
    BBACommentContentLinkTypeLookImage = 4 // 查看图片
};

/// 【10.5新增】转发同时评论，定义富文本链接图片类型
typedef NS_ENUM(NSInteger, BBACommentContentLinkIconType) {
    BBACommentContentLinkIconTypeNone = 0,  // 无
    BBACommentContentLinkIconTypeLink = 1,  // 网页链接
    BBACommentContentLinkIconTypeVideo = 2,  // 视频活动链接
    BBACommentContentLinkIconTypeVote = 3,  // 投票活动链接
    BBACommentContentLinkIconTypeLookImage = 4 // 查看图片
};

typedef NS_ENUM(NSInteger, BDPCommentContentLinkSourceType) {
    BDPCommentContentLinkSourceTypeDuXiaoHuVideo = 1,
    BDPCommentContentLinkSourceTypeDuXiaoHuSearch = 2
};

FOUNDATION_EXPORT  NSString *const BBACommentContentLinkTextAttributeName;

@interface BBACommentContentLinkAttribute : NSObject <NSCopying>

/**
 链接Icon类型
 */
@property (nonatomic, assign) BBACommentContentLinkIconType iconType;

/**
 调起协议
 */
@property (nonatomic, strong) NSString *scheme;

/**
 用户UK
 */
@property (nonatomic, strong) NSString *uk;

@property (nonatomic, strong) NSString *personalPageSchema;

/// url字段
@property (nonatomic, copy) NSString *url;

/// text字段
@property (nonatomic, copy) NSString *text;

+ (instancetype)itemWithDict:(NSDictionary *)dict;

/**
 返回链接前面图标名字
 */
- (NSString *)linkIconName;

@end

@interface BBACommentContentLink : NSObject <NSCopying>

/**
 链接类型：话题 2：链接 3：用户
 */
@property (nonatomic, assign) BBACommentContentLinkType linkType;

/// 链接类型：1度小糊视频 2度小糊搜索
@property (nonatomic, assign) BDPCommentContentLinkSourceType sourceType;

@property (nonatomic, assign, readonly) BOOL isDuXiaoHuLink;

/**
 链接描述信息
 */
@property (nonatomic, strong) BBACommentContentLinkAttribute *linkAttribute;

/**
 标识符
 */
@property (nonatomic, strong, readonly) NSString *identiferString;

/**
 链接表示的原文本
 */
@property (nonatomic, strong, readonly) NSAttributedString *text;

/**
 自定义信息存储位置
 */
@property (nonatomic, copy, readonly) NSDictionary *userInfo;

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


- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIdentifer:(NSString *)identifer text:(NSAttributedString *)text userInfo:(NSDictionary *)userInfo;

+ (instancetype)itemWithDict:(NSDictionary *)dict;

/**
 返回UBC链接打点type
 */
- (NSString *)clickType;

@end
