//
//  PBQRCodeScanView.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/23.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBQRCodeScanView.h"
#import <AVFoundation/AVFoundation.h>
#import "PBQRCodeScan.h"

@interface PBQRCodeScanView ()<PBQRCodeScanDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *scanLineImageView;
@property (nonatomic, weak) CALayer *scanContentLayer;
@property (nonatomic, strong) PBQRCodeScan *qrCodeScan;

@end

#define KPBScanContentX (self.frame.size.width * 0.15)
#define KPBScanContentY (self.frame.size.height * 0.24)
#define KPBScanContentOutsideViewAlpha 0.4
#define KPBScanLineHeight 12
#define KPBScanLineAnimation 0.05

@implementation PBQRCodeScanView

+ (id)qrCodeScanViewWithFrame:(CGRect)frame andCurrentController:(UIViewController *)currentController {
    return [[self alloc]initWithFrame:frame andCurrentController:currentController];
}

- (id)initWithFrame:(CGRect)frame andCurrentController:(UIViewController *)currentController {
    if ([super initWithFrame:frame]) {
        CALayer *layer = currentController.view.layer;
        
        // 扫描框
        CALayer *scanContentLayer = [[CALayer alloc]init];
        self.scanContentLayer = scanContentLayer;
        [layer addSublayer:scanContentLayer];
        scanContentLayer.frame = CGRectMake(KPBScanContentX, KPBScanContentY, self.frame.size.width - KPBScanContentX * 2, self.frame.size.width - KPBScanContentX * 2);
        scanContentLayer.borderColor = [[UIColor whiteColor]colorWithAlphaComponent:0.6].CGColor;
        scanContentLayer.borderWidth = 0.7;
        scanContentLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        // 扫描框顶部
        CALayer *topLayer = [[CALayer alloc]init];
        [self.layer addSublayer:topLayer];
        topLayer.frame = CGRectMake(0, 0, self.frame.size.width, KPBScanContentY);
        topLayer.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:KPBScanContentOutsideViewAlpha].CGColor;
        //topLayer.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:KPBScanContentOutsideViewAlpha].CGColor;
        
        // 扫描框左部
        CALayer *leftLayer = [[CALayer alloc]init];
        [self.layer addSublayer:leftLayer];
        leftLayer.frame = CGRectMake(0, KPBScanContentY, KPBScanContentX, scanContentLayer.frame.size.height);
        leftLayer.backgroundColor = topLayer.backgroundColor;
        //leftLayer.backgroundColor = [[UIColor blueColor]colorWithAlphaComponent:KPBScanContentOutsideViewAlpha].CGColor;
        
        // 扫描框右部
        CALayer *rightLayer = [[CALayer alloc]init];
        [self.layer addSublayer:rightLayer];
        rightLayer.frame = CGRectMake(CGRectGetMaxX(scanContentLayer.frame), KPBScanContentY, KPBScanContentX, scanContentLayer.frame.size.height);
        rightLayer.backgroundColor = topLayer.backgroundColor;
        //rightLayer.backgroundColor = [[UIColor blueColor]colorWithAlphaComponent:KPBScanContentOutsideViewAlpha].CGColor;
        
        // 扫描框底部
        CALayer *bottomLayer = [[CALayer alloc]init];
        [self.layer addSublayer:bottomLayer];
        bottomLayer.frame = CGRectMake(0, CGRectGetMaxY(scanContentLayer.frame), self.frame.size.width, self.frame.size.height-CGRectGetMaxY(scanContentLayer.frame));
        bottomLayer.backgroundColor = topLayer.backgroundColor;
        //bottomLayer.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:KPBScanContentOutsideViewAlpha].CGColor;
        
        // 扫描框左上角图标
        UIImageView *leftImageView = [[UIImageView alloc]init];
        [layer addSublayer:leftImageView.layer];
        leftImageView.image = [UIImage imageNamed:@"qrcode_lefttop"];
        leftImageView.frame = CGRectMake(CGRectGetMinX(scanContentLayer.frame), CGRectGetMinY(scanContentLayer.frame), leftImageView.image.size.width, leftImageView.image.size.height);
        
        // 扫描框右上角图标
        UIImageView *rightImageView = [[UIImageView alloc]init];
        [layer addSublayer:rightImageView.layer];
        rightImageView.image = [UIImage imageNamed:@"qrcode_righttop"];
        rightImageView.frame = CGRectMake(CGRectGetMaxX(scanContentLayer.frame)-rightImageView.image.size.width, CGRectGetMinY(scanContentLayer.frame), rightImageView.image.size.width, rightImageView.image.size.height);
        
        // 扫描框左下角图标
        UIImageView *leftdownImageView = [[UIImageView alloc]init];
        [layer addSublayer:leftdownImageView.layer];
        leftdownImageView.image = [UIImage imageNamed:@"qrcode_leftbottom"];
        leftdownImageView.frame = CGRectMake(CGRectGetMinX(scanContentLayer.frame), CGRectGetMaxY(scanContentLayer.frame)-leftdownImageView.image.size.height, leftdownImageView.image.size.width, leftdownImageView.image.size.height);
        
        // 扫描框右下角图标
        UIImageView *rightdownImageView = [[UIImageView alloc]init];
        [layer addSublayer:rightdownImageView.layer];
        rightdownImageView.image = [UIImage imageNamed:@"qrcode_rightbottom"];
        rightdownImageView.frame = CGRectMake(CGRectGetMaxX(scanContentLayer.frame)-rightdownImageView.image.size.width, CGRectGetMaxY(scanContentLayer.frame)-rightdownImageView.image.size.height, rightdownImageView.image.size.width, rightdownImageView.image.size.height);
        
        // 扫描提示语
        UILabel *promptLab = [[UILabel alloc]init];
        [self addSubview:promptLab];
        promptLab.frame = CGRectMake(0, KPBScanContentY - 30 - 25, self.frame.size.width, 25);
        promptLab.font = [UIFont boldSystemFontOfSize:13];
        promptLab.textAlignment = NSTextAlignmentCenter;
        promptLab.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.6];
        promptLab.text = @"将二维码/条形码放入框内,即可自动扫描";
        
        // 手电筒
        UIButton *flashlightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:flashlightBtn];
        flashlightBtn.frame = CGRectMake((self.frame.size.width - 30) / 2, CGRectGetMaxY(scanContentLayer.frame) + 50, 30, 30);
        [flashlightBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_flashlightopenimage"] forState:UIControlStateNormal];
        [flashlightBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_flashlightcloseimage"] forState:UIControlStateSelected];
        [flashlightBtn addTarget:self action:@selector(flashlightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 扫描线
        UIImageView *scanLineImageView = [[UIImageView alloc]init];
        self.scanLineImageView = scanLineImageView;
        [layer addSublayer:scanLineImageView.layer];
        scanLineImageView.image = [UIImage imageNamed:@"qrcode_scanningline"];
        //scanLineImageView.frame = CGRectMake(KPBScanContentX, KPBScanContentY, self.frame.size.width - 2 * KPBScanContentX, KPBScanLineHeight);
        scanLineImageView.frame = CGRectMake(KPBScanContentX, KPBScanContentY, self.frame.size.width - 2 * KPBScanContentX, KPBScanLineHeight);
        //scanLineImageView.backgroundColor = [UIColor redColor];
        
#if TARGET_IPHONE_SIMULATOR
        
#elif TARGET_OS_IPHONE
        // 扫描行为
        PBQRCodeScan *qrCodeScan = [PBQRCodeScan sharedQRCodeScan];
        self.qrCodeScan = qrCodeScan;
        NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        [qrCodeScan qrCodeScanWithSessionPreset:AVCaptureSessionPreset1920x1080 andMetadataObjectTypes:arr andScanContentLayer:scanContentLayer andCurrentController:currentController];
        qrCodeScan.delegate = self;
#endif
    }
    return self;
}

- (void)qrCodeScan:(PBQRCodeScan *)qrCodeScan andDidOutputWithResult:(NSString *)result {
    if ([self.delegate respondsToSelector:@selector(qrCodeScanView:andDidOutputWithResult:)]) {
        [self.delegate qrCodeScanView:self andDidOutputWithResult:result];
    }
}

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:KPBScanLineAnimation target:self selector:@selector(scanLineAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
}

- (void)startScan {
    [self startTimer];
    
    // 开始扫描
    [self.qrCodeScan.session startRunning];
}

- (void)stopScan {
    [self stopTimer];
    
    // 停止扫描
    [self.qrCodeScan.session stopRunning];
}

- (void)scanLineAction {
    if (self.scanLineImageView.frame.origin.y < CGRectGetMaxY(self.scanContentLayer.frame) - KPBScanLineHeight) {
        [UIView animateWithDuration:KPBScanLineAnimation animations:^{
            CGRect rect = self.scanLineImageView.frame;
            rect.origin.y = rect.origin.y + 5;
            self.scanLineImageView.frame = rect;
        }];
    } else {
        CGRect rect = self.scanLineImageView.frame;
        rect.origin.y = KPBScanContentY;
        self.scanLineImageView.frame = rect;
    }
}

- (void)flashlightBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    NSLog(@"btn.selected = %d", btn.selected);
    
    if (btn.selected == NO) {
        NSLog(@"关闭手电筒");
        {
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            if ([device hasTorch]) {
                [device lockForConfiguration:nil];
                device.torchMode = AVCaptureTorchModeOff;
                [device unlockForConfiguration];
            }
        }
    } else {
        NSLog(@"开启手电筒");
        {
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            if ([device hasTorch]) {
                [device lockForConfiguration:nil];
                device.torchMode = AVCaptureTorchModeOn;
                [device unlockForConfiguration];
            }
        }
    }
}

- (void)dealloc {
    NSLog(@"PBQRCodeScanView对象被释放了");
}

@end
