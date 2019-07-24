//
//  PBQRCodeScan.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/23.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBQRCodeScan.h"
#import <UIKit/UIKit.h>

static id sharedQRCodeScan = nil;

@interface PBQRCodeScan ()<AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation PBQRCodeScan

+ (id)sharedQRCodeScan {
    if (sharedQRCodeScan == nil) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            sharedQRCodeScan = [[self alloc]init];
        });
    }
    return sharedQRCodeScan;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedQRCodeScan = [super allocWithZone:zone];
    });
    return sharedQRCodeScan;
}

// 扫描行为
- (void)qrCodeScanWithSessionPreset:(NSString *)sessionPreset andMetadataObjectTypes:(NSArray *)metadataObjectTypes andScanContentLayer:(CALayer *)scanContentLayer andCurrentController:(UIViewController *)currentController {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc]init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    metadataOutput.rectOfInterest = CGRectMake(scanContentLayer.frame.origin.y/currentController.view.frame.size.height, scanContentLayer.frame.origin.x/currentController.view.frame.size.width, scanContentLayer.frame.size.height/currentController.view.frame.size.height, scanContentLayer.frame.size.width/currentController.view.frame.size.width); // (y, x, h, w)比例
    
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    self.session = session;
    session.sessionPreset = sessionPreset;
    [session addInput:deviceInput];
    [session addOutput:metadataOutput];
    
    // 下面语句必须放在此处执行
    metadataOutput.metadataObjectTypes = metadataObjectTypes;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    videoPreviewLayer.frame = currentController.view.layer.bounds;
    [currentController.view.layer insertSublayer:videoPreviewLayer atIndex:0];
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"metadataObjects = %@", metadataObjects);
    
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *codeObject = [metadataObjects firstObject];
        NSString *result = codeObject.stringValue;
        
        if ([self.delegate respondsToSelector:@selector(qrCodeScan:andDidOutputWithResult:)]) {
            // 停止扫描
            [self.session stopRunning];
            
            [self.delegate qrCodeScan:self andDidOutputWithResult:result];
        }
    } else {
        NSLog(@"暂未识别出扫描的二维码");
    }
}

- (void)dealloc {
    NSLog(@"PBQRCodeScan对象被释放了");
}

@end
