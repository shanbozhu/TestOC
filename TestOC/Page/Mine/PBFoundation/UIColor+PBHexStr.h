//
//  UIColor+PBHexStr.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/5/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (PBHexStr)

+ (UIColor *)bba_RGBColorFromHexString:(NSString *)aHexStr;
+ (UIColor *)bba_RGBColorFromHexString:(NSString *)aHexStr alpha:(float)aAlpha;

@end

NS_ASSUME_NONNULL_END
