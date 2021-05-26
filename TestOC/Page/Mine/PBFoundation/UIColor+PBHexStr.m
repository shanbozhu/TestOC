//
//  UIColor+PBHexStr.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "UIColor+PBHexStr.h"

#define CHECK_STRING_VALID(targetString) \
([targetString isKindOfClass:[NSString class]] && targetString.length > 0)

@implementation UIColor (PBHexStr)

//16进制颜色值与浮点型颜色值的转换
+ (CGFloat)bba_colorChannelFromHexString:(NSString *)hexString {
    int num[2] = {0};
    for (int i = 0 ; i < 2; i++) {
        int asc = [hexString characterAtIndex:i];
        // 数字
        if (asc >= '0' && asc <= '9') {
            num[i] = asc - '0';
        }
        // 大写字母
        else if (asc >= 'A' && asc <= 'F') {
            num[i] = asc - 'A' + 10;
        }
        // 小写字母
        else if (asc >= 'a' && asc <= 'f') {
            num[i] = asc - 'a' + 10;
        }
    }
    return (num[0] * 16 + num[1]) / 255.;
}

+ (UIColor *)bba_RGBColorFromHexString:(NSString *)aHexStr
                                 alpha:(float)aAlpha {
    if ([aHexStr isKindOfClass:[NSString class]]
        && CHECK_STRING_VALID(aHexStr)
        && aHexStr.length > 6) {// #rrggbb 大小写字母及数字
        CGFloat redValue = [UIColor bba_colorChannelFromHexString:[aHexStr substringWithRange:NSMakeRange(1, 2)]];
        CGFloat greenValue = [UIColor bba_colorChannelFromHexString:[aHexStr substringWithRange:NSMakeRange(3, 2)]];
        CGFloat blueValue = [UIColor bba_colorChannelFromHexString:[aHexStr substringWithRange:NSMakeRange(5, 2)]];
        UIColor *rgbColor = [UIColor colorWithRed:redValue
                                            green:greenValue
                                             blue:blueValue
                                            alpha:aAlpha];
        return rgbColor;
    }
    return [UIColor blackColor]; // 默认黑色
}

@end
