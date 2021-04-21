//
//  PBContentLink.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/21.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PBContentLinkTextAttributeName;

typedef NS_ENUM(NSInteger, PBContentLinkType) {
    PBContentLinkTypeAt = 1,           // 用户
    PBContentLinkTypeTopic = 2,        // 话题
    PBContentLinkTypeLink = 3,         // 网页链接
    PBContentLinkTypeLookImage = 4     // 查看图片
};

typedef NS_ENUM(NSInteger, PBContentLinkIconType) {
    PBContentLinkIconTypeNone = 0,       // 无
    PBContentLinkIconTypeLink = 1,       // 网页链接
    PBContentLinkIconTypeVideo = 2,      // 视频活动链接
    PBContentLinkIconTypeVote = 3,       // 投票活动链接
    PBContentLinkIconTypeLookImage = 4   // 查看图片
};

@interface PBContentLinkAttribute : NSObject

/// 链接icon类型
@property (nonatomic, assign) PBContentLinkIconType iconType;

+ (instancetype)itemWithDict:(NSDictionary *)dict;

@end

@interface PBContentLink : NSObject

@property (nonatomic, assign) PBContentLinkType linkType;

@property (nonatomic, strong) PBContentLinkAttribute *linkAttribute;

@property (nonatomic, strong) UIColor *highlightedTextColor;

@property (nonatomic, strong) UIColor *highlightedBackgourndColor;


- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIdentifer:(NSString *)identifer text:(NSAttributedString *)text userInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
