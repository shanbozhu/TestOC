//
//  PBContentController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/14.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBContentController.h"
#import "BBAEmoticonTextAttachment.h"
#import "BBACommentContentLabel.h"
#import "PBContentLabel.h"
#import "PBContentLabelItem.h"

#define fontsize 19

#define kBBACommentReplyFontSize 19
#define kBBACommentReplyLineSpace 5
NSString *const kBBAEmoticonPlainTextPttern = @"\\[[0-9a-zA-Z\\u4e00-\\u9fa5]+\\]";

@interface PBContentController ()

@end

@implementation PBContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    NSMutableAttributedString *attributedString = [self responseString];
    
    //
    BBACommentContentLabelItem *contentItem = [BBACommentContentLabelItem itemWithAttributedString:attributedString width:250 maximumNumberOfLines:0];
    
    //
    BBACommentContentLabel *lab = [[BBACommentContentLabel alloc] init];
    [self.view addSubview:lab];
    lab.layer.borderColor = [UIColor redColor].CGColor;
    lab.layer.borderWidth = 1;
    lab.backgroundColor = [UIColor whiteColor];
    
    lab.frame = CGRectMake(50, APPLICATION_NAVIGATIONBAR_HEIGHT + 50, contentItem.currrentLayoutItem.size.width, 0);
    lab.contentLabelItem = contentItem;
    lab.pb_height = contentItem.currrentLayoutItem.size.height;
}

- (NSMutableAttributedString *)responseString {

    NSMutableAttributedString *responseString = [NSMutableAttributedString new];

    
    UIFont *respontFont = [UIFont systemFontOfSize:kBBACommentReplyFontSize];
    [responseString appendAttributedString:[self userNameWithUserInfo]];
    NSMutableDictionary *responseStrAttribute = @{}.mutableCopy;
    [responseStrAttribute setObject:respontFont forKey:NSFontAttributeName];

    NSMutableAttributedString *responseContent = [[NSMutableAttributedString alloc] initWithString:@"：哈哈[0022]😇" attributes:responseStrAttribute];

    
    // 替换评论内容中的表情标签
    responseContent = [self translateAllPlainTextToEmoticonWithAttributedString:responseContent].mutableCopy;
    [responseString appendAttributedString:responseContent];
    
    //行间距
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = kBBACommentReplyLineSpace;
    [responseString addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, responseString.length)];
    
    return responseString;
}

- (NSAttributedString *_Nullable)translateAllPlainTextToEmoticonWithAttributedString:(NSAttributedString *_Nonnull)anAttributedString {
    if (![anAttributedString isKindOfClass:[NSAttributedString class]]) {
        return nil;
    }
    NSString *sourceStr = anAttributedString.string;
    // 先复制待转换富文本，然后只是把其中的转义字符替换掉。
    NSMutableAttributedString *resultAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:anAttributedString];
    NSError *error = nil;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:kBBAEmoticonPlainTextPttern options:NSRegularExpressionCaseInsensitive error:&error];
    __block NSInteger offset = 0;
    [regExp enumerateMatchesInString:sourceStr
                             options:0
                               range:NSMakeRange(0, [sourceStr length])
                          usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                              @autoreleasepool {
                                  NSRange range = result.range;
                                  NSDictionary *attributes = [anAttributedString attributesAtIndex:range.location effectiveRange:NULL];
                                  UIFont *font = [attributes objectForKey:NSFontAttributeName];
                                  ///当前匹配到的字符串处理
                                  NSString *curString = [sourceStr substringWithRange:result.range];
                                  // 获取匹配到的字符串对应的表情，有可能为nil
//                                  BBAEmoticonItem *emoticonItem = [[BBAEmoticonLibrary sharedInstance] emoticonItemWithPlainText:curString];
                                  // 获取表情的富文本
                                  NSAttributedString *emoticonAttr = [self emoticonAttributedStringWithFont:font plainText:curString];
                                  if (emoticonAttr) {
                                      NSAttributedString *result1 = emoticonAttr;
                                      if (attributes) {
                                          NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:emoticonAttr];
                                          [str addAttributes:attributes range:NSMakeRange(0, str.length)];
                                          result1 = [[NSAttributedString alloc] initWithAttributedString:str];
                                      }
                                      NSRange newRange = NSMakeRange(range.location-offset, range.length);
                                      [resultAttributedString replaceCharactersInRange:newRange withAttributedString:result1];
                                      offset += (range.length - result1.length);
                                  }
                              }
                          }];
    return resultAttributedString;
}

- (NSMutableAttributedString *__nullable)emoticonAttributedStringWithFont:(UIFont *__nullable)font plainText:(NSString *)plainText {
    BBAEmoticonTextAttachment *attachment = [self emoticonAttachmentWithFont:font plainText:plainText];
    if (!attachment) {
        return nil;
    }
    NSMutableAttributedString *resutlt = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    if (font) {
        NSDictionary *attributes = @{NSFontAttributeName : font};
        [resutlt addAttributes:attributes range:NSMakeRange(0, resutlt.length)];
    }
    return resutlt;
}

- (BBAEmoticonTextAttachment *__nullable)emoticonAttachmentWithFont:(UIFont *__nullable)font  plainText:(NSString *)plainText {
    BBAEmoticonTextAttachment *attachment = [[BBAEmoticonTextAttachment alloc] init];
    attachment.plainText = plainText;
    attachment.image = [UIImage imageNamed:@"0022"];
    attachment.font = font;
    return attachment;
}

- (NSAttributedString *)userNameWithUserInfo
{
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] init];
    NSAttributedString *pureNameString = [self pureUserName];
    [nameString appendAttributedString:pureNameString];
    
    //
    BBACommentContentLink *link = [[BBACommentContentLink alloc] initWithIdentifer:@"repliedUserLinkString" text:nameString userInfo:nil];
    link.linkType = BBACommentContentLinkTypeAt;
    link.linkAttribute = [[BBACommentContentLinkAttribute alloc] init];
    
    link.highlightedTextColor = [UIColor redColor];
    link.highlightedBackgourndColor = [UIColor lightGrayColor];
    [nameString addAttribute:BBACommentContentLinkTextAttributeName value:link range:NSMakeRange(0, nameString.length)];

    return [[NSAttributedString alloc] initWithAttributedString:nameString];
}

- (NSAttributedString *)pureUserName {
    
    NSString *userName = @"test9527波波test9527波波test9527波波test9527波波test9527波波";
    
    UIFont *nameFont = [UIFont systemFontOfSize:kBBACommentReplyFontSize];
    NSDictionary *nameStrAttribute = @{NSForegroundColorAttributeName:[UIColor blueColor],
                                       NSFontAttributeName:nameFont};
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:userName attributes:nameStrAttribute];
    return nameString;
}

@end
