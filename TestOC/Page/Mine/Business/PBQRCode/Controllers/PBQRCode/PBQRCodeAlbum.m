//
//  PBQRCodeAlbum.m
//  TestOC
//
//  Created by DaMaiIOS on 17/8/31.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBQRCodeAlbum.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

static id sharedQRCodeAlbum = nil;

@interface PBQRCodeAlbum ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UIViewController *currentController;

@end

@implementation PBQRCodeAlbum

+ (id)sharedQRCodeAlbum {
    if (sharedQRCodeAlbum == nil) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            sharedQRCodeAlbum = [[self alloc]init];
        });
    }
    return sharedQRCodeAlbum;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedQRCodeAlbum = [super allocWithZone:zone];
    });
    return sharedQRCodeAlbum;
}

- (void)qrCodeAlbumWithCurrentController:(UIViewController *)currentController {
    self.currentController = currentController;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
                imagePickerController.hidesBottomBarWhenPushed = YES;
                [currentController presentViewController:imagePickerController animated:YES completion:nil];
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePickerController.delegate = self;
            } else {
                NSLog(@"用户第一次拒绝了访问相册权限");
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.hidesBottomBarWhenPushed = YES;
        [currentController presentViewController:imagePickerController animated:YES completion:nil];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
    } else if (status == PHAuthorizationStatusDenied) {
        NSString *appName = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleName"];
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"请前往 -> [设置 - 隐私 - 照片 - %@] 打开访问开关", appName] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
    } else if (status == PHAuthorizationStatusRestricted) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"由于系统原因,无法访问相册" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (features != nil && features.count > 0) {
        CIQRCodeFeature *feature = [features lastObject];
        NSString *result = feature.messageString;
        
        [self.currentController dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(qrCodeAlbum:andDidFinishPickingMediaWithResult:)]) {
                [self.delegate qrCodeAlbum:self andDidFinishPickingMediaWithResult:result];
            }
        }];
    } else {
        NSLog(@"暂未识别出扫描的二维码");
        [self.currentController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc {
    NSLog(@"PBQRCodeAlbum对象被释放了");
}

@end
