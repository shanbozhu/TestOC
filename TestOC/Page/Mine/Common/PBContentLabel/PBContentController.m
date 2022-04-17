//
//  PBContentController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/14.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBContentController.h"
#import "BBACommentContentLabel.h"
#import "BBAEmoticonManager.h"

#define fontsize 19

#define kBBACommentReplyFontSize 19
#define kBBACommentReplyLineSpace 10

@interface PBContentController ()<BBACommentContentLabelDelegate>

@end

@implementation PBContentController

- (void)viewDidLoad {
    [super viewDidLoad];

    //
    NSMutableAttributedString *attributedString = [self responseString];

    //
    BBACommentContentLabelItem *contentItem = [BBACommentContentLabelItem itemWithAttributedString:attributedString maxWidth:250 maximumNumberOfLines:0];

    //
    BBACommentContentLabel *lab = [[BBACommentContentLabel alloc] init];
    [self.view addSubview:lab];
    lab.layer.borderColor = [UIColor redColor].CGColor;
    lab.layer.borderWidth = 1;
    lab.backgroundColor = [UIColor whiteColor];
    lab.delegate = self;

    lab.frame = CGRectMake(50, APPLICATION_NAVIGATIONBAR_HEIGHT + 50, contentItem.layoutItem.size.width, 0);
    lab.contentLabelItem = contentItem;
    lab.pb_height = contentItem.layoutItem.size.height;
}

- (void)contentLabel:(BBACommentContentLabel *)label linkDidClicked:(BBACommentContentLink *)link {
    NSLog(@"link.range = %@", NSStringFromRange(link.range));
}

- (NSMutableAttributedString *)responseString {

    NSMutableAttributedString *responseString = [NSMutableAttributedString new];

    // test9527波波
    [responseString appendAttributedString:[self userNameWithUserInfo]];
    
    // ：哈哈[调皮]😇
    NSMutableAttributedString *responseContent = [[NSMutableAttributedString alloc] initWithString:@"：哈哈[调皮][调皮]😇" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kBBACommentReplyFontSize], NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    // 替换评论内容中的表情标签[0022]为富文本
    [[BBAEmoticonManager alloc] translateAllPlainTextToEmoticonWithAttributedString:responseContent];
    [responseString appendAttributedString:responseContent];
    
    //行间距
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = kBBACommentReplyLineSpace;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    [responseString addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, responseString.length)];
    
    return responseString;
}

- (NSAttributedString *)userNameWithUserInfo
{
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:@"test9527波波test9527波波test9527波波test9527波波test9527波波"];
//    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:@"test9527波波"];
    
    //
    BBACommentContentLink *link = [[BBACommentContentLink alloc] init];
    link.linkAttribute = [[BBACommentContentLinkAttribute alloc] init];
    link.highlightedTextColor = [UIColor redColor];
    link.highlightedBackgourndColor = [UIColor lightGrayColor];
    
    [nameString addAttribute:BBACommentContentLinkTextAttributeName value:link range:NSMakeRange(0, nameString.length)];
    [nameString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:kBBACommentReplyFontSize] range:NSMakeRange(0, nameString.length)];
    [nameString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, nameString.length)];

    return nameString;
}

@end
