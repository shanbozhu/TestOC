//
//  BBACommentContentLink.h
//  BBAComs-BBAComment
//
//  Created by liuyang108 on 2018/1/29.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const BBACommentContentLinkTextAttributeName;

@interface BBACommentContentLinkAttribute : NSObject

@end

@interface BBACommentContentLink : NSObject

@property (nonatomic, strong) BBACommentContentLinkAttribute *linkAttribute;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) NSArray *rects;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIColor *highlightedBackgourndColor;

@end
