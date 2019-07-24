//
//  PBQRCodeGenerate.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/21.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBQRCodeGenerate.h"

@implementation PBQRCodeGenerate

+ (UIImage *)qrCodeGenerateWithQRCodeStr:(NSString *)qrCodeStr andQRCodeWidth:(CGFloat)qrCodeWidth {
    // 创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:[qrCodeStr dataUsingEncoding:NSUTF8StringEncoding] forKeyPath:@"inputMessage"];
    CIImage *outputImage = [filter outputImage];
    
    return [self createUIImageFromCIImage:outputImage andImageWidth:qrCodeWidth];
}

+ (UIImage *)createUIImageFromCIImage:(CIImage *)image andImageWidth:(CGFloat)imageWidth {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(imageWidth/CGRectGetWidth(extent), imageWidth/CGRectGetHeight(extent));
    
    // 创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

+ (UIImage *)qrCodeGenerateWithQRCodeStr:(NSString *)qrCodeStr andIconImage:(UIImage *)iconImage andIconScale:(CGFloat)scale {
    // 创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:[qrCodeStr dataUsingEncoding:NSUTF8StringEncoding] forKeyPath:@"inputMessage"];
    CIImage *outputImage = [filter outputImage];
    
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    
    UIImage *startImage = [UIImage imageWithCIImage:outputImage];
    
    UIGraphicsBeginImageContext(startImage.size);
    
    [startImage drawInRect:CGRectMake(0, 0, startImage.size.width, startImage.size.height)];
    
    [iconImage drawInRect:CGRectMake((startImage.size.width-startImage.size.width * scale) * 0.5, (startImage.size.height-startImage.size.height * scale) * 0.5, startImage.size.width * scale, startImage.size.height * scale)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}

@end
