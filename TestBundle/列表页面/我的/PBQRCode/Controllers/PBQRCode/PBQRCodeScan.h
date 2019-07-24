//
//  PBQRCodeScan.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/23.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class PBQRCodeScan;
@protocol PBQRCodeScanDelegate <NSObject>

- (void)qrCodeScan:(PBQRCodeScan *)qrCodeScan andDidOutputWithResult:(NSString *)result;

@end

@interface PBQRCodeScan : NSObject

@property (nonatomic, weak) id<PBQRCodeScanDelegate> delegate;

@property (nonatomic, strong) AVCaptureSession *session;

+ (id)sharedQRCodeScan;

- (void)qrCodeScanWithSessionPreset:(NSString *)sessionPreset andMetadataObjectTypes:(NSArray *)metadataObjectTypes andScanContentLayer:(CALayer *)scanContentLayer andCurrentController:(UIViewController *)currentController;

@end
