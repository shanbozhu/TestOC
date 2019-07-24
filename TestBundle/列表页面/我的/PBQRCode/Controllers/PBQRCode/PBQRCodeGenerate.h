//
//  PBQRCodeGenerate.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/21.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PBQRCodeGenerate : NSObject

+ (UIImage *)qrCodeGenerateWithQRCodeStr:(NSString *)qrCodeStr andQRCodeWidth:(CGFloat)qrCodeWidth;

+ (UIImage *)qrCodeGenerateWithQRCodeStr:(NSString *)qrCodeStr andIconImage:(UIImage *)iconImage andIconScale:(CGFloat)scale;

@end
