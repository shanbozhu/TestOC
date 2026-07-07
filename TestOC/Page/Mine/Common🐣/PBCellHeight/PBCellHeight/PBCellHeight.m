//
//  PBCellHeight.m
//  TestOC
//
//  Created by DaMaiIOS on 17/6/15.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import "PBCellHeight.h"
#import <objc/runtime.h>

@implementation NSString (PBCellHeight)

// 判断是否含有中文
- (BOOL)pb_containChinese:(NSString *)str {
    for (int i = 0; i < str.length; i++) {
        int a = [str characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

// 显示全部内容的文本高度
- (CGSize)pb_boundingSizeWithWidth:(CGFloat)width andFont:(UIFont *)font andLineSpacing:(CGFloat)lineSpacing {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self];
    
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.length)];
    
    if (lineSpacing > 0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = lineSpacing;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.length)];
    }
        
    UILabel *lab = [[UILabel alloc]init];
    lab.numberOfLines = 0;
    lab.frame = CGRectMake(0, 0, width, 0);
    lab.attributedText = attributedString;
    [lab sizeToFit];
    
    CGRect rect;
    rect.size.width = lab.frame.size.width;
    rect.size.height = lab.frame.size.height;
    
    // 系统字体显示一行且含有中文的时候会显示行间距
    if (([font.fontName isEqualToString:@".SFUIText"] || [font.fontName isEqualToString:@".SFUIDisplay"]) && rect.size.height < (font.lineHeight * 2 + lineSpacing) && [self pb_containChinese:self]) {
        return CGSizeMake(rect.size.width, rect.size.height - lineSpacing);
    }
    
    return rect.size;
}

// 显示至多numberOfLines内容的文本高度
- (CGSize)pb_boundingSizeWithWidth:(CGFloat)width andFont:(UIFont *)font andLineSpacing:(CGFloat)lineSpacing andNumberOfLines:(NSInteger)numberOfLines {
    if (numberOfLines <= 0) {
        CGSize size = [self pb_boundingSizeWithWidth:width andFont:font andLineSpacing:lineSpacing];
        return CGSizeMake(size.width, ceilf(size.height));
    }
    
    // 最大高度
    CGFloat maxHeight = numberOfLines * font.lineHeight + (numberOfLines - 1) * lineSpacing;
    
    CGSize size = [self pb_boundingSizeWithWidth:width andFont:font andLineSpacing:lineSpacing];
    
    if (size.height > maxHeight) {
        return CGSizeMake(size.width, ceilf(maxHeight));
    } else {
        return CGSizeMake(size.width, ceilf(size.height));
    }
}

@end
