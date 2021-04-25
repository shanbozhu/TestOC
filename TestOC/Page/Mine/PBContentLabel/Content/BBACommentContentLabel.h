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

@interface BBACommentContentLabel : UIView

@property (nonatomic, weak) id<BBACommentContentLabelDelegate> delegate;

@property (nonatomic, strong) id<BBACommentContentLabelTextProtocol> contentLabelItem;

@end

@protocol BBACommentContentLabelDelegate <NSObject>

- (void)contentLabel:(BBACommentContentLabel *)label linkDidClicked:(BBACommentContentLink *)link;

@end
