//
//  BBACommentItem.m
//  BBAComs
//
//  Created by liuyang108 on 2017/5/22.
//
//

#import "BBACommentContent.h"
#import "BBACommentContentLink.h"
//#import "BBACommentListParser.h"

@implementation BBACommentUserInfo
//-(id)copyWithZone:(NSZone *)zone {
//    BBACommentUserInfo *copy = [[self class] new];
//    copy.userName = _userName;
//    copy.identity = _identity;
//    copy.uk = _uk;
//    copy.personalPageSchema = _personalPageSchema;
//    copy.avatar = _avatar;
//    copy.isBjhAuthor = _isBjhAuthor;
//    copy.bjhUserName = _bjhUserName;
//    copy.starType = _starType;
//    copy.starName = _starName;
//    copy.starID = _starID;
//    copy.starAvatar = _starAvatar;
//    copy.vLogoType = _vLogoType;
//    copy.heatRank = self.heatRank;
//    copy.heatIcon = self.heatIcon;
//    copy.cmd = self.cmd;
//    copy.nickNameColor = self.nickNameColor;
//    copy.pendantUrl = self.pendantUrl;
//    copy.authorID = self.authorID;
//    copy.subscribed = self.subscribed;
//    copy.isFriend = self.isFriend;
//    return copy;
//}

///// 真正需要展示的 username
//- (NSString *)userNameToShow {
//    NSString *userName = @"";
//    if (CHECK_STRING_VALID(self.starName)) {
//        userName = self.starName;
//    } else if(CHECK_STRING_VALID(self.bjhUserName)) {
//        userName = self.bjhUserName;
//    } else if (CHECK_STRING_VALID(self.userName)){
//        userName = self.userName;
//    }
//    return userName;
//}

/// 真正需要展示的用户头像
- (NSString *)avatarToShow {
    NSString *avatar = nil;
    if ([self isStar]) {
        avatar = self.starAvatar;
    } else {
        avatar = self.avatar;
    }
    return avatar;
}

/// 判断是不是明星用户
//- (BOOL)isStar {
//    return CHECK_STRING_VALID(self.starName);
//}

- (BOOL)isAuthor {
    return self.isBjhAuthor;
}

- (BOOL)isLandlord {
    return self.is_lz;
}

//- (BOOL)isShowHeat {
//    if (CHECK_STRING_VALID(self.heatIcon)) {
//        return YES;
//    }
//    return NO;
//}

//- (BOOL)isValid {
//    return CHECK_STRING_VALID(self.uk);
//}

- (NSString *)relation {
    if (self.isFriend) {
        return @"通讯录好友";
    }
    if (self.subscribed) {
        return @"已关注";
    }
    return nil;
}

@end


@interface BBACommentContent ()

@end

@implementation BBACommentContent

//- (instancetype)initWithDict:(NSDictionary *)dict {
////    if (!BBAIsDictionary(dict)) {
////        return nil;
////    }
//    self = [super init];
//    if (self) {
//        _isTopComment = YES;
//        [self reloadFromInfoDict:dict];
//    }
//    return self;
//}
//
//+ (instancetype)itemWithDict:(NSDictionary *)dict {
//    return [[[self class] alloc] initWithDict:dict];
//}
//
//- (NSString *)shareContent {
//    __block NSString *shareContent = @"";
//    if (CHECK_STRING_VALID(self.content)) {
//        shareContent = self.content.copy;
//    }
//    [self.links enumerateObjectsUsingBlock:^(BBACommentContentLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (BBACommentContentLinkTypeLookImage == obj.linkType) {
//            shareContent = [NSString stringWithFormat:@"%@[图片]", shareContent];
//            *stop = YES;
//        }
//    }];
//    return shareContent;
//}
///**
// 【10.5新增】解析评论内容链接信息，包括网页链接，@用户名字，话题链接
// 
// @param dictsArray 评论内容链接信息
// @return 链接对象（BBACommentContentLink）数组
// */
//+ (NSMutableArray<BBACommentContentLink *> *)contentLinksWithDicts:(NSArray<NSDictionary *> *)dictsArray block:(void(^)(BBACommentContentLink *link))block {
//    if (![dictsArray isKindOfClass:[NSArray class]]) {
//        return nil;
//    }
//    NSMutableArray *items = [NSMutableArray arrayWithCapacity:dictsArray.count];
//    for (NSDictionary *dict in dictsArray) {
//        if (!BBAIsDictionary(dict)) {
//            continue;
//        }
//        BBACommentContentLink *item = [BBACommentContentLink itemWithDict:dict];
//        if (item) {
//            [items addObject:item];
//            if (block) {
//                block(item);
//            }
//        }
//    }
//    return items;
//}
//
//#pragma mark -
//+ (BOOL)checkCommentValid:(BBACommentContent *)item {
//    return item && [item isKindOfClass:[BBACommentContent class]] && CHECK_STRING_VALID(item.topicID) && CHECK_STRING_VALID(item.replyID);
//}
//
//- (void)reloadFromInfoDict:(NSDictionary *)dict {
//    self.topicID = [dict bba_stringValueForKey:@"topic_id"];
//    self.replyID = [dict bba_stringValueForKey:@"reply_id"];
//    self.commentFrom = [dict bba_stringValueForKey:@"cmt_from"];
//    self.portrait = [dict bba_stringValueForKey:@"portrait"];
//    self.createTime = [dict bba_numberValueForKey:@"create_time"];
//    self.likeCount = [[dict bba_numberValueForKey:@"like_count"] integerValue];
//    self.dislikeCount = [[dict bba_numberValueForKey:@"dislike_count"] integerValue];
//    self.content = [dict bba_stringValueForKey:@"content"];
//    self.triple = [dict bba_stringValueForKey:@"triple"];
//    self.scrollTop = [dict bba_stringValueForKey:@"scrollTop"];
//   
//    self.replyCount = [[dict bba_numberValueForKey:@"reply_count"] integerValue];
//    self.is_uped = [[dict bba_numberValueForKey:@"is_uped"] boolValue];
//    self.author_uped = [[dict bba_numberValueForKey:@"author_uped"] boolValue];
//    self.hotLevel = [[dict bba_numberValueForKey:@"hot_level"] integerValue];
//    self.isBomb = [[dict bba_numberValueForKey:@"is_bomb"] boolValue];
//    self.is_self = [[dict bba_stringValueForKey:@"is_self"] boolValue];
//    self.fromType = [[dict bba_numberValueForKey:@"type"] integerValue];
//    self.isShowStatus = [[dict bba_numberValueForKey:@"show_status"] boolValue];
//    self.authorFavor = [[dict bba_stringValueForKey:@"author_favor"] boolValue];
//    
//    // 11.13 评论B端用户外露关注按钮
//    self.thirdID = [dict bba_stringValueForKey:@"third_id"];
//    self.userType = [dict bba_stringValueForKey:@"user_type"];
//    self.isAttention = [[dict bba_numberValueForKey:@"attention"] boolValue];
//    
//    NSArray *viewpointsInfo = [dict bba_arrayValueForKey:@"comment_tag"];
//    NSMutableArray *viewpoints = [[NSMutableArray alloc] initWithCapacity:viewpointsInfo.count];
//    [viewpointsInfo enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isKindOfClass:NSDictionary.class]) {
//            BBACommentViewpointModel *model = [BBACommentViewpointModel commentViewpointModelWithDic:obj];
//            [viewpoints addObject:model];
//        }
//    }];
//    self.viewpoints = viewpoints;
//    //评论发布者信息
//    self.userInfo = [[BBACommentUserInfo alloc] init];
//    self.userInfo.userName = [dict bba_stringValueForKey:@"uname"];
//    self.userInfo.identity = [dict bba_stringValueForKey:@"verified"];
//    self.userInfo.isFriend = [[dict bba_stringValueForKey:@"is_friend"] isEqualToString:@"1"];
//    self.userInfo.subscribed = [[dict bba_stringValueForKey:@"is_subscribe"] isEqualToString:@"1"];
//    self.userInfo.authorID = [dict bba_stringValueForKey:@"third_id"];
//    self.userInfo.uk = [dict bba_stringValueForKey:@"uk"];
//    self.userInfo.personalPageSchema = [dict bba_stringValueForKey:@"personalpage_schema"];
//    self.userInfo.isBjhAuthor = [[dict bba_stringValueForKey:@"_bjh_is_author"] boolValue];
//    self.userInfo.is_lz = [[dict bba_stringValueForKey:@"is_lz"] boolValue];
//    self.userInfo.bjhUserName = [dict bba_stringValueForKey:@"_bjh_uname"];
//    self.userInfo.avatar = [dict bba_stringValueForKey:@"avatar"];
//    self.userInfo.vLogoType = [[dict bba_numberValueForKey:@"vtype"] integerValue];
//    NSDictionary *commentor = [dict bba_dictionaryValueForKey:@"commentor"];
//    self.userInfo.heatRank = [commentor bba_stringValueForKey:@"level"];
//    self.userInfo.heatIcon = [commentor bba_stringValueForKey:@"icon"];
//    self.userInfo.cmd = [commentor bba_stringValueForKey:@"url"];
//    self.userInfo.pendantUrl = [commentor bba_stringValueForKey:@"pendant"];
//    self.userInfo.nickNameColor = [commentor bba_stringValueForKey:@"color"];
//    
//    self.badges = [dict bba_arrayValueForKey:@"decorations"];
//    
//    //被回复者信息
//    self.replyUserInfo = [[BBACommentUserInfo alloc] init];
//    self.replyUserInfo.userName = [dict bba_stringValueForKey:@"reply_to_uname"];
//    self.replyUserInfo.uk = [dict bba_stringValueForKey:@"reply_to_uk"];
//    self.replyUserInfo.personalPageSchema = [dict bba_stringValueForKey:@"reply_to_personalpage_schema"];
//    //self.userInfo.isAuthor = [[dict bba_numberValueForKey:@"reply_to_is_author"] boolValue];
//    self.replyUserInfo.isBjhAuthor = [[dict bba_stringValueForKey:@"_bjh_replyed_is_author"] boolValue];
//    self.replyUserInfo.bjhUserName = [dict bba_stringValueForKey:@"_bjh_replyed_uname"];
//    self.replyUserInfo.vLogoType = [[dict bba_numberValueForKey:@"reply_to_vtype"] integerValue];
//
//    NSDictionary *starInfo = [dict bba_dictionaryValueForKey:@"_star"];
//    if (starInfo) {
//        self.userInfo.starType = [starInfo bba_stringValueForKey:@"type"];
//        self.userInfo.starName = [starInfo bba_stringValueForKey:@"uname"];
//        self.userInfo.starID = [starInfo bba_stringValueForKey:@"mr_id"];
//        self.userInfo.starAvatar = [starInfo bba_stringValueForKey:@"avatar"];
//        
//        self.replyUserInfo.starType = [starInfo bba_stringValueForKey:@"replyed_type"];
//        self.replyUserInfo.starName = [starInfo bba_stringValueForKey:@"replyed_uname"];
//        self.replyUserInfo.starAvatar = [starInfo bba_stringValueForKey:@"replyed_avatar"];
//    }
//
//    //回复列表
//    NSArray *replyList = [dict bba_arrayValueForKey:@"reply_list"];
//    if (CHECK_ARRAY_VALID(replyList)) {
//        self.replyList = @[].mutableCopy;
//        [BBACommentListParser itemsArrayWithDicts:replyList listInfo:nil convertIterator:^(id<BBACommentItemProtocol> item, BDPCommentServerConfig *config, NSInteger idx) {
//            if ([item.commentContent isKindOfClass:BBACommentContent.class]) {
//                BBACommentContent *content = (BBACommentContent *)item.commentContent;
//                content.isTopComment = NO;
//                [self.replyList addObject:content];
//            }
//        }];
//    } else {
//        self.replyList = [NSMutableArray array];
//    }
//    
//    NSArray *replyToComments = [dict bba_arrayValueForKey:@"reply_to_comment"];
//    if (CHECK_ARRAY_VALID(replyToComments)) {
//        self.replyToCommentsList = [BBACommentListParser itemsArrayWithUserIndependentStyleDicts:replyToComments];
//    } else {
//        self.replyToCommentsList = [NSMutableArray array];
//    }
//    
//    // 内容链接信息
//    NSArray *linkList = [dict bba_arrayValueForKey:@"content_rich"];
//    if (CHECK_ARRAY_VALID(linkList)) {
//        self.links = [BBACommentContent contentLinksWithDicts:linkList block:^(BBACommentContentLink *link) {
//            if (link.sourceType == BDPCommentContentLinkSourceTypeDuXiaoHuVideo || link.sourceType == BDPCommentContentLinkSourceTypeDuXiaoHuSearch) {
//                self.hasDuXiaoHuLink = YES;
//                self.linkSourceType = link.sourceType;
//            }
//        }];
//    } else {
//        self.links = [NSMutableArray array];
//    }
//}
//
//- (BOOL)needAddLookupImageLink {
//    // 只有在评论是一级评论时，并且不是回复其他评论同时评论原文的评论才会添加查看图片
//    if (self.isTopComment && CHECK_ARRAY_INVALID(self.replyToCommentsList)) {
//        return NO;
//    }
//    return YES;
//}
//
//- (instancetype)copyWithZone:(NSZone *)zone {
//    BBACommentContent *copy = [self.class new];
//    copy.topicID = self.topicID;
//    copy.replyID = self.replyID;
//    copy.parent_id = self.parent_id;
//    copy.portrait = self.portrait;
//    copy.createTime = self.createTime;
//    copy.commentFrom = self.commentFrom;
//    copy.likeCount = _likeCount;
//    copy.dislikeCount = _dislikeCount;
//    copy.content = self.content;
//    copy.replyCount = _replyCount;
//    copy.thirdID = _thirdID;
//    copy.userType = _userType;
//    copy.isAttention = self.isAttention;
//    copy.replyList = self.replyList.mutableCopy;
//    copy.is_uped = self.is_uped;
//    copy.author_uped = self.author_uped;
//    copy.hotLevel = self.hotLevel;
//    copy.isBomb = self.isBomb;
//    copy.replyToCommentsList = self.replyToCommentsList.mutableCopy;
//    copy.userInfo = [self.userInfo copy];
//    copy.replyUserInfo = [self.replyUserInfo copy];
//    copy.links = self.links.mutableCopy;
//    copy.fromType = _fromType;
//    copy.is_self = self.is_self;
//    copy.viewpoints = self.viewpoints;
//    copy.isTopComment = _isTopComment;
//    copy.commentFromDetail188 = self.commentFromDetail188;
//    copy.hasDuXiaoHuLink = self.hasDuXiaoHuLink;
//    copy.linkSourceType = self.linkSourceType;
//    copy.badges = self.badges;
//    copy.triple = self.triple;
//    copy.scrollTop = self.scrollTop;
//    return copy;
//}
//
//- (BBACommentCellViewModel *)viewModel {
//    if (!_viewModel) {
//        _viewModel = [BBACommentCellViewModel new];
//    }
//    return _viewModel;
//}

////MARK: logic
//- (BOOL)isEqualToContent:(id<BBACommentContentProtocol>)content {
//    if (![content isKindOfClass:self.class]) {
//        return NO;
//    }
//    BBACommentContent *item = (BBACommentContent *)content;
//    if (![BBACommentContent checkCommentValid:self] || ![BBACommentContent checkCommentValid:item]) {
//        return NO;
//    }
//    if ([self.topicID isEqualToString:item.topicID] && [self.replyID isEqualToString:item.replyID]) {
//        return YES;
//    }
//    return NO;
//    
//}

@end

