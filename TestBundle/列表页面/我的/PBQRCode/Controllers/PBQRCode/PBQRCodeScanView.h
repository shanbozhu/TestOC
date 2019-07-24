//
//  PBQRCodeScanView.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/23.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class PBQRCodeScanView;
@protocol PBQRCodeScanViewDelegate <NSObject>

- (void)qrCodeScanView:(PBQRCodeScanView *)qrCodeScanView andDidOutputWithResult:(NSString *)result;

@end


@interface PBQRCodeScanView : UIView

@property (nonatomic, weak) id<PBQRCodeScanViewDelegate> delegate;

+ (id)qrCodeScanViewWithFrame:(CGRect)frame andCurrentController:(UIViewController *)currentController;

- (void)startScan;
- (void)stopScan;

@end
