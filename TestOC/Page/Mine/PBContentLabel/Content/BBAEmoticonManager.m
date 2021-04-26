//
//  BBAEmoticonManager.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "BBAEmoticonManager.h"
#import "PBRegex.h"
#import "BBAEmoticonTextAttachment.h"

@implementation BBAEmoticonManager

- (NSAttributedString *)translateAllPlainTextToEmoticonWithAttributedString:(NSMutableAttributedString *)attStr {
    NSArray *result = [[PBRegex regexEmoticon] matchesInString:attStr.string options:kNilOptions range:NSMakeRange(0, attStr.length)];
    for (NSInteger i = result.count - 1; i >= 0; i--) {
        NSTextCheckingResult *at = [result objectAtIndex:i];
        if (at.range.location == NSNotFound && at.range.length <= 1) {
            continue;
        }
        NSString *rangeString = [attStr.string substringWithRange:at.range];
        
        // 将转义字符替换为对应的图片名称
        NSString *imageName = [self imageNameWithRangeString:rangeString];
        if (!imageName) {
            continue;
        }
        
        NSDictionary *attributes = [attStr attributesAtIndex:at.range.location effectiveRange:NULL];
        UIFont *font = [attributes objectForKey:NSFontAttributeName];
        
        // 将图片生成富文本
        BBAEmoticonTextAttachment *attachment = [[BBAEmoticonTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:imageName];
        attachment.font = font;
        NSAttributedString *resutlt = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSMutableAttributedString *emoticon = [[NSMutableAttributedString alloc] initWithAttributedString:resutlt];
        [emoticon addAttributes:attributes range:NSMakeRange(0, resutlt.length)];
        
        // 替换子串后改变了原字符串的长度,会改变其他子串的初始位置,此时替换会越界.从右往左替换则不会出现此问题,因为其他子串的位置不会因为后面子串的改变而改变.
        [attStr replaceCharactersInRange:at.range withAttributedString:emoticon];
    }
    return attStr;
}


- (NSString *)imageNameWithRangeString:(NSString *)rangeString {
    if ([rangeString isEqualToString:@"[调皮]"]) {
        return @"0022";
    } else if ([rangeString isEqualToString:@"[大调皮]"]) {
        return @"002";
    }
    return nil;
}

@end
