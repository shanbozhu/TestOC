//
//  BBACommentContentLabel.h
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/22.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBACommentContentLink.h"
#import "BBACommentContentLabelItem.h"

@protocol BBACommentContentLabelDelegate;

/**
 评论内容展示文本视图
 展示实现BBACommentContentLabelTextProtocol协议的文本约束对象，@see BBACommentContentLabelTextProtocol;
 */
@interface BBACommentContentLabel : UIView

@property (nonatomic, weak) id<BBACommentContentLabelDelegate>delegate;

@property (nonatomic, strong) id<BBACommentContentLabelTextProtocol>contentLabelItem;

@end

@protocol BBACommentContentLabelDelegate <NSObject>

/**
 正在展示的文本串中的链接被点击

 @param label 链接文本所在的文本视图 @see BBACommentContentLabel
 @param link 被点击的链接对象 @see BBACommentContentLink
 */
- (void)contentLabel:(BBACommentContentLabel *)label linkDidClicked:(BBACommentContentLink *)link;

@end
