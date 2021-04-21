//
//  BBACommentContentLink.m
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/29.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BBACommentContentLink.h"

NSString *const BBACommentContentLinkTextAttributeName = @"BBACommentContentLinkTextAttributeName";


@interface BBACommentContentLink ()

@property (nonatomic, strong) NSString *identiferString;
@property (nonatomic, strong) NSAttributedString *text;
@property (nonatomic, copy) NSDictionary *userInfo;

@end

@implementation BBACommentContentLink

- (instancetype)initWithIdentifer:(NSString *)identifer text:(NSAttributedString *)text userInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        self.identiferString = identifer;
        self.text = text;
        self.userInfo = userInfo;
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
//    if (!BBAIsDictionary(dict)) {
//        return nil;
//    }
    self = [super init];
    if (self) {
//        self.linkType = [[dict bba_numberValueForKey:@"type"] integerValue];
//        self.range = NSMakeRange([[dict bba_numberValueForKey:@"start"] integerValue], [[dict bba_numberValueForKey:@"length"] integerValue]);
//        NSDictionary *attr = [dict bba_dictionaryValueForKey:@"attr"];
//        self.linkAttribute = [BBACommentContentLinkAttribute itemWithDict:attr];
//        self.sourceType = [[attr bba_stringValueForKey:@"ext_type"] integerValue];
    }
    return self;
}

+ (instancetype)itemWithDict:(NSDictionary *)dict {
    return [[[self class] alloc] initWithDict:dict];
}

- (id)copyWithZone:(NSZone *)zone {
    BBACommentContentLink *copy = [[[self class] allocWithZone:zone] init];
    copy.linkType = _linkType;
    copy.range = _range;
    copy.linkAttribute = [_linkAttribute copyWithZone:zone];
    copy.sourceType = _sourceType;
    return copy;
}

- (BOOL)isDuXiaoHuLink {
    return self.sourceType == BDPCommentContentLinkSourceTypeDuXiaoHuVideo || self.sourceType == BDPCommentContentLinkSourceTypeDuXiaoHuSearch;
}

- (NSString *)clickType {
    if (self.linkType == BBACommentContentLinkTypeAt) {
        return @"aut_click";
    } else if (self.linkType == BBACommentContentLinkTypeTopic){
        return @"topic_click";
    } else if (self.linkType == BBACommentContentLinkTypeLink){
        return @"link_click";
    }
    return nil;
}

@end

@implementation BBACommentContentLinkAttribute

- (instancetype)initWithDict:(NSDictionary *)dict {
//    if (!BBAIsDictionary(dict)) {
//        return nil;
//    }
    self = [super init];
    if (self) {
//        self.uk = [dict bba_stringValueForKey:@"uk"];
//        self.personalPageSchema = [dict bba_stringValueForKey:@"personalpage_schema"];
//        self.scheme = [dict bba_stringValueForKey:@"scheme"];
//        self.iconType = [[dict bba_numberValueForKey:@"icon"] integerValue];
//        self.url = [dict bba_stringValueForKey:@"url"];
//        self.text = [dict bba_stringValueForKey:@"text"];
    }
    return self;
}

+ (instancetype)itemWithDict:(NSDictionary *)dict {
    return [[[self class] alloc] initWithDict:dict];
}

- (id)copyWithZone:(NSZone *)zone {
    BBACommentContentLinkAttribute *copy = [[[self class] allocWithZone:zone] init];
    copy.iconType = _iconType;
    copy.scheme = [_scheme copyWithZone:zone];
    copy.uk = [_uk copyWithZone:zone];
    copy.personalPageSchema = [_personalPageSchema copyWithZone:zone];
    copy.url = self.url;
    copy.text = self.text;
    return copy;
}

- (NSString *)linkIconName {
    switch (self.iconType) {
        case BBACommentContentLinkIconTypeLink:
            return @"BBAComment_comment_link_icon_web";
        case BBACommentContentLinkIconTypeVideo:
            return @"BBAComment_comment_link_icon_video";
        case BBACommentContentLinkIconTypeVote:
            return @"BBAComment_comment_link_icon_vote";
        case BBACommentContentLinkIconTypeLookImage:
            return @"BBAComment_comment_link_icon_image";
        default:
            break;
    }
    return nil;
}

@end
