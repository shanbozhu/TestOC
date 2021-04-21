//
//  BBACommentItem.h
//  BBAComs
//
//  Created by liuyang108 on 2017/5/22.
//
//

#import <Foundation/Foundation.h>
#import "BBACommentContentText.h"
//#import "BBACommentCellViewModel.h"
//#import "BBACommentViewpointModel.h"
//#import "BBACommentContentProtocol.h"
#import "BBACommentContentLink.h"

@class BBACommentCellViewModel;
@class BBACommentContent;

typedef NS_ENUM(NSInteger,BBACommentVLogoType)
{
    BBACommentVLogoTypeNoAuth = 0,  //无认证;
    BBACommentVLogoTypeGloden = 1,  //金V
    BBACommentVLogoTypeBlue = 2,   //蓝V
    BBACommentVLogoTypeYellow = 3,  //黄V
    BBACommentVLogoTypeAuth = 10,    //认证
    BBACommentVLogoTypeEnd
};

// 评论来源，1. 评论发表  2. UCG动态转发
typedef NS_ENUM(NSInteger, BBACommentFromType) {
    BBACommentFromTypeNomal = 0, // 普通评论
    BBACommentFromTypeComment = 1,  // 弹幕
    BBACommentFromTypeUGC = 2, // UGC动态转发
    BBACommentFromTypeLocalImage = 3, // 用户上传图片
    BBACommentFromTypeServerImage = 4 // 服务端检索图片
};

typedef NS_ENUM(NSUInteger, BBACommentShowStatus) {
    BBACommentShowStatusNormal = 0, // 0 可以发
    BBACommentShowStatusDisable = 1, // 1 评论关闭
    BBACommentShowStatusOnlySelf = 3, // 3评论自己可见
};

typedef NS_ENUM(NSUInteger, BBACommentHotLevel) {
    BBACommentHotLevelNormal = 0, // 0 普通评论
    BBACommentHotLevelHot = 1, // 1 热门评论
    BBACommentHotLevelGod = 2, // 2 神评
};

@interface BBACommentUserInfo : NSObject <NSCopying>
/// 用户名
@property (nonatomic, copy) NSString *userName;
/// 身份认证标识
@property (nonatomic, copy) NSString *identity;
/// 当前用户与该评论作者的关系（通讯录好友、已关注）
@property (nonatomic, copy, readonly) NSString *relation;
/// 评论作者用户id；百家号对应id，ugc用户是uk
@property (nonatomic, copy) NSString *authorID;
/// 已关注
@property (nonatomic, assign) BOOL subscribed;
/// 通讯录好友
@property (nonatomic, assign) BOOL isFriend;
/// 用户uk
@property (nonatomic, copy) NSString *uk;

@property (nonatomic, copy) NSString *personalPageSchema;

@property (nonatomic, copy) NSString *avatar;             //头像

@property (nonatomic, assign) BOOL isBjhAuthor;             //是否是百家号作者【当是百家号作者时，才会下发此字段】， 如果是需要在用户名后边添加"[作者]"标签
@property (nonatomic, assign) BOOL is_lz;                   //是否是楼主
@property (nonatomic, copy) NSString *bjhUserName;        //百家号作者名【当是百家号作者时，才会下发此字段】

@property (nonatomic, copy) NSString *starType;           //明星类型
@property (nonatomic, copy) NSString *starName;           //明星姓名，显示此用户名
@property (nonatomic, copy) NSString *starID;             //明星ID
@property (nonatomic, copy) NSString *starAvatar;         //头像
@property (nonatomic, assign) BBACommentVLogoType vLogoType;         // V标类型 0 无认证; 1 金V; 2蓝V; 3黄V; 10 认证。(9.3.5)

/// 是否展示评论家视图
@property (nonatomic, assign, readonly) BOOL isShowHeat;
/// 评论家icon
@property (nonatomic, copy) NSString *heatIcon;
/// 评论家级别
@property (nonatomic, copy) NSString *heatRank;
/// 点击要打开的协议
@property (nonatomic, copy) NSString *cmd;
/// 头像挂件url
@property (nonatomic, copy) NSString *pendantUrl;
/// 昵称颜色，16进制色值
@property (nonatomic, copy) NSString *nickNameColor;


/// 真正需要展示的 username
- (NSString *)userNameToShow;

/// 真正需要展示的用户头像
- (NSString *)avatarToShow;

/// 判断是不是明星用户
- (BOOL)isStar;

- (BOOL)isAuthor;                //是否是文章作者
- (BOOL)isLandlord;              //是否是评论楼主

- (BOOL)isValid;

@end

@class BBACommentContentLabelItem;


@class BBACommentContentLink;
@class BBACommentCellViewModel;
@class BBACommentOperationModel;

//@interface BBACommentContent : NSObject <NSCopying, BBACommentContentProtocol>
@interface BBACommentContent : NSObject <NSCopying>
/// 主题ID
@property (nonatomic, copy) NSString *topicID;
/// 评论ID
@property (nonatomic, copy) NSString *replyID;
/// 父评论ID
@property (nonatomic, copy) NSString *parent_id;
///
@property (nonatomic, copy) NSString *portrait;
/// 评论发表时间
@property (nonatomic, strong) NSNumber *createTime;
/// 点赞数
@property (nonatomic, assign) NSInteger likeCount;
/// 踩数
@property (nonatomic, assign) NSInteger dislikeCount;
/// 评论内容
@property (nonatomic, copy) NSString *content;
/// 评论来源 1普通评论 2智能评论 10.10新增字段
@property (nonatomic, copy) NSString *commentFrom;
/// 被回复数
@property (nonatomic, assign) NSInteger replyCount;
/// 11.13 关注ID
@property (nonatomic, copy) NSString *thirdID;
/// 11.13 关注用户类型
@property (nonatomic, copy) NSString *userType;
/// 11.13 是否在评论区外漏关注按钮新样式
@property (nonatomic, assign) BOOL isAttention;
/// 此条评论外露的回复评论
@property (nonatomic, strong) NSMutableArray<BBACommentContent *>*replyList;
/// 是否点赞过
@property (nonatomic, assign) BOOL is_uped;
/// 是否作者点赞过
@property (nonatomic, assign) BOOL author_uped;
/// 是否“炸”过
@property (nonatomic, assign) BOOL isBomb;
/// 评论类型 0：普通评论 1：热评 2：神评
@property (nonatomic, assign) BBACommentHotLevel hotLevel;
/// 是否是自己所见评论
@property (nonatomic, assign) BOOL is_self;
/// 是否是可外露的评论
@property (nonatomic, assign) BOOL isShowStatus;
/// 11.24 作者置顶评论
@property (nonatomic, assign) BOOL authorFavor;
/// 11.24 评论长按操作
@property (nonatomic, strong) BBACommentOperationModel *operationModel;
//12.0点赞三连标识
@property(nonatomic, copy) NSString *triple;
//12.0标识是否自动刷新
@property(nonatomic, copy) NSString *scrollTop;

/**
 * 用户徽章列表，格式如下
 * {"url" : "",
 * "icon": "",
 * "source": 1(评论家)}
 */
@property (nonatomic, copy) NSArray<NSDictionary *> *badges;

/// 被此条评论回复的评论，index代表层级
@property (nonatomic, strong) NSMutableArray<BBACommentContent *>*replyToCommentsList;
/// 评论发布者信息
@property (nonatomic, strong) BBACommentUserInfo *userInfo;
/// 被回复用户信息
@property (nonatomic, strong) BBACommentUserInfo *replyUserInfo;

/// 【10.5新增】// 评论来源，0普通评论，1弹幕，2ugc动态转发，3本地图片，4sogif动图 
@property (nonatomic, assign) BBACommentFromType fromType;
/// 【10.5新增】评论内容中链接描述信息
@property (nonatomic, strong) NSMutableArray<BBACommentContentLink *>*links;
/// 是否需要在评论内容后面拼接『icon+查看图片』
@property (nonatomic, assign, readonly) BOOL needAddLookupImageLink;
/// 是否是一级评论
@property (nonatomic, assign) BOOL isTopComment;

/// 是否带有度小糊的超链接
@property (nonatomic, assign) BOOL hasDuXiaoHuLink;

@property (nonatomic, assign) BDPCommentContentLinkSourceType linkSourceType;

@property (nonatomic, strong) BBACommentCellViewModel *viewModel;

@property (nonatomic, strong, readonly) NSString *shareContent;

/// 观点标签
//@property (nonatomic, copy) NSArray<BBACommentViewpointModel *> *viewpoints;

/// 188接口下发的数据，评论详情
@property (nonatomic, assign) BOOL commentFromDetail188;
/**
 判断评论对象是否可用
 
 @param item 待判断的评论对象
 @return BOOL 评论对象是否可用
 */
+ (BOOL)checkCommentValid:(BBACommentContent *)item;

@end

@interface BBACommentContent (logic)

/**
 是否是当前用户发表的评论
 
 @return BOOL
 */
- (BOOL)isCreatedByCurrentUser;

/// 是否展示观点标签
- (BOOL)shouldShowViewpointLabel;
//显示点赞三连标签
- (NSString *)showPraiseTripleLabel;

@end

@interface BBACommentContent (Protect)

/**
 从评论列表／详情接口返回的评论数据进行初始化
 
 @param dict 评论列表／详情接口返回的评论数据
 @return BBACommentItem * 评论对象
 */
- (instancetype)initWithDict:(NSDictionary *)dict;

/**
 返回从评论列表／详情接口返回的评论数据进行初始化的评论对象
 
 @param dict 评论列表／详情接口返回的评论数据
 @return BBACommentItem * 评论对象
 */
+ (instancetype)itemWithDict:(NSDictionary *)dict;

@end
