//
//  PBQRCodeController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBQRCodeController.h"
#import "PBQRCodeGenerateController.h"
#import "PBQRCodeScanController.h"
#import <AVFoundation/AVFoundation.h>

@interface PBQRCodeController ()

@end

@implementation PBQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(100, 200, ([UIScreen mainScreen].bounds.size.width-100)/2, 50);
    [btn setTitle:@"生成二维码" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.userInteractionEnabled = YES;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 0;
    
    UIButton *twoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:twoBtn];
    twoBtn.frame = CGRectMake(100, 300, ([UIScreen mainScreen].bounds.size.width-100)/2, 50);
    [twoBtn setTitle:@"扫描二维码" forState:UIControlStateNormal];
    [twoBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    twoBtn.userInteractionEnabled = YES;
    [twoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    twoBtn.tag = 1;
}

- (void)btnClick:(UIButton *)btn {
    if (btn.tag == 0) {
        PBQRCodeGenerateController *qrCodeGenerateController = [[PBQRCodeGenerateController alloc]init];
        qrCodeGenerateController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:qrCodeGenerateController animated:YES];
        qrCodeGenerateController.view.backgroundColor = [UIColor colorWithWhite:0.87 alpha:1.0];
    } else {
#if TARGET_IPHONE_SIMULATOR
        PBQRCodeScanController *qrCodeScanController = [[PBQRCodeScanController alloc]init];
        qrCodeScanController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:qrCodeScanController animated:YES];
        //qrCodeScanController.view.backgroundColor = [UIColor whiteColor];
#elif TARGET_OS_IPHONE
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device != nil) {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (status == AVAuthorizationStatusNotDetermined) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted == YES) {
                        PBQRCodeScanController *qrCodeScanController = [[PBQRCodeScanController alloc]init];
                        qrCodeScanController.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:qrCodeScanController animated:YES];
                        //qrCodeScanController.view.backgroundColor = [UIColor whiteColor];
                    } else {
                        NSLog(@"用户第一次拒绝了访问相机权限");
                    }
                }];
            } else if (status == AVAuthorizationStatusAuthorized) {
                PBQRCodeScanController *qrCodeScanController = [[PBQRCodeScanController alloc]init];
                qrCodeScanController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:qrCodeScanController animated:YES];
                //qrCodeScanController.view.backgroundColor = [UIColor whiteColor];
            } else if (status == AVAuthorizationStatusDenied) {
                NSString *appName = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleName"];
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"请前往 -> [设置 - 隐私 - 相机 - %@] 打开访问开关", appName] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [al show];
            } else if (status == AVAuthorizationStatusRestricted) {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"由于系统原因,无法访问相机" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [al show];
            }
        } else {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"未检测到您的摄像头" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [al show];
        }
#endif
    }
}

@end
