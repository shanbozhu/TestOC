//
//  BBAEmoticonTextAttachment.m
//  ExpressionDemo
//
//  Created by liuyang108 on 2017/9/6.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "BBAEmoticonTextAttachment.h"
 
@implementation BBAEmoticonTextAttachment

- (void)setFont:(UIFont *)font {
    _font = font;
    if (_font) {
        
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
        
        CGFloat height = font.lineHeight * scale;
        CGSize imageSize = self.image.size;
        CGFloat width = (imageSize.height > 0 ? (imageSize.width * height / imageSize.height) : 0);
        self.bounds = CGRectMake(self.bounds.origin.x, font.descender + (font.lineHeight - height)/2.f, width, height);
    }
}

@end
