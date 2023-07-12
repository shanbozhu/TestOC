//
//  BBAEmoticonManager.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "BBAEmoticonManager.h"
#import "PBRegex.h"

@implementation BBAEmoticonTextAttachment

+ (instancetype)emoticonTextAttachmentWithImage:(NSString *)imageName font:(UIFont *)font {
    return [[self alloc] initWithImage:imageName font:font];
}

- (instancetype)initWithImage:(NSString *)imageName font:(UIFont *)font {
    if (self = [super init]) {
        self.image = [UIImage imageNamed:imageName];
        
        CGFloat scale = [self scaleWithFont:font];
        CGFloat height = font.lineHeight * scale;
        CGSize imageSize = self.image.size;
        CGFloat width = (imageSize.height > 0 ? (imageSize.width * height / imageSize.height) : 0);
        self.bounds = CGRectMake(self.bounds.origin.x, font.descender + (font.lineHeight - height)/2.f, width, height);
    }
    return self;
}

- (CGFloat)scaleWithFont:(UIFont *)font {
    // 计算scale 参考Emoji表情变化规律得出
    CGFloat scale = 1.f;
    CGFloat fontSize = font.pointSize;
    if (fontSize <= 6.f) {
        scale = 1.1f;
    } else if (fontSize < 11.f) {
        scale = 1.f + (fontSize - 6.f)/(11.f - 6.f) * (1.04f - 1.f);
    } else if (fontSize == 11.f) {
        scale =  1.f;
    } else if (fontSize < 14.f) {
        scale = 1.f + (fontSize - 11.f)/(14.f - 11.f) * (1.04f - 1.f);
    } else if (fontSize == 14.f) {
        scale =  1.04f;
    } else if (fontSize < 17.f) {
        scale = 1.04f + (fontSize - 14.f)/(17.f - 14.f) * (1.f - 1.04f);
    } else if (fontSize == 17.f) {
        scale =  1.f;
    } else if (fontSize < 24.f) {
        scale = 1.f + (fontSize - 17.f)/(24.f - 17.f) * (0.8f - 1.f);
    } else {
        scale = 0.8f;
    }
    return scale;
}

@end

@implementation BBAEmoticonManager

- (void)translateAllPlainTextToEmoticonWithAttributedString:(NSMutableAttributedString *)attributedString {
    NSArray *result = [[PBRegex regexEmoticon] matchesInString:attributedString.string options:kNilOptions range:NSMakeRange(0, attributedString.length)];
    for (NSInteger i = result.count - 1; i >= 0; i--) {
        NSTextCheckingResult *at = [result objectAtIndex:i];
        if (at.range.location == NSNotFound && at.range.length <= 1) {
            continue;
        }
        NSString *rangeString = [attributedString.string substringWithRange:at.range];
        
        // 将转义字符替换为对应的图片名称
        NSString *imageName = [self imageNameWithRangeString:rangeString];
        if (!imageName) {
            continue;
        }
        
        NSRange range = at.range;
        NSDictionary *attributes = [attributedString attributesAtIndex:range.location effectiveRange:&range];
        UIFont *font = [attributes objectForKey:NSFontAttributeName];
        
        // 将图片生成富文本
        BBAEmoticonTextAttachment *attachment = [BBAEmoticonTextAttachment emoticonTextAttachmentWithImage:imageName font:font];
        
        NSAttributedString *resutlt = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSMutableAttributedString *emoticon = [[NSMutableAttributedString alloc] initWithAttributedString:resutlt];
        [emoticon addAttributes:attributes range:NSMakeRange(0, resutlt.length)];
        
        // 替换子串后改变了原字符串的长度,会改变其他子串的初始位置,此时替换会越界.从右往左替换则不会出现此问题,因为其他子串的位置不会因为后面子串的改变而改变.
        [attributedString replaceCharactersInRange:at.range withAttributedString:emoticon];
    }
}

#pragma mark - 表情扩展

- (NSString *)imageNameWithRangeString:(NSString *)rangeString {
    if ([rangeString isEqualToString:@"[调皮]"]) {
        return @"001";
    } else if ([rangeString isEqualToString:@"[大调皮]"]) {
        return @"0001";
    }
    return nil;
}

@end
