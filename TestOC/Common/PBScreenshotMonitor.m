//
//  PBScreenshotMonitor.m
//  TestOC
//
//  Created by Codex on 2026/7/8.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBScreenshotMonitor.h"
#import <QuartzCore/QuartzCore.h>

NSNotificationName const PBScreenshotMonitorDidTakeScreenshotNotification = @"PBScreenshotMonitorDidTakeScreenshotNotification";
NSString * const PBScreenshotMonitorScreenshotDateKey = @"PBScreenshotMonitorScreenshotDateKey";
NSString * const PBScreenshotMonitorApplicationStateKey = @"PBScreenshotMonitorApplicationStateKey";
NSString * const PBScreenshotMonitorScreenshotImageKey = @"PBScreenshotMonitorScreenshotImageKey";

@interface PBScreenshotMonitor ()

@property (nonatomic, assign, getter=isMonitoring) BOOL monitoring;
@property (nonatomic, strong) UIImageView *screenshotPreviewImageView;

@end

@implementation PBScreenshotMonitor

+ (instancetype)sharedMonitor {
    static PBScreenshotMonitor *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[PBScreenshotMonitor alloc] init];
    });
    return monitor;
}

- (void)startMonitoring {
    if (self.isMonitoring) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
    self.monitoring = YES;
}

- (void)stopMonitoring {
    if (!self.isMonitoring) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationUserDidTakeScreenshotNotification
                                                  object:nil];
    self.monitoring = NO;
}

- (void)userDidTakeScreenshot:(NSNotification *)notification {
    NSDate *date = [NSDate date];
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    UIImage *snapshotImage = [self currentWindowSnapshotImage];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[PBScreenshotMonitorScreenshotDateKey] = date;
    userInfo[PBScreenshotMonitorApplicationStateKey] = @(applicationState);
    if (snapshotImage) {
        userInfo[PBScreenshotMonitorScreenshotImageKey] = snapshotImage;
        [self showScreenshotPreviewWithImage:snapshotImage];
    }
    
    NSLog(@"监听到系统截图事件，date = %@, applicationState = %ld", date, (long)applicationState);
    [[NSNotificationCenter defaultCenter] postNotificationName:PBScreenshotMonitorDidTakeScreenshotNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (nullable UIImage *)currentWindowSnapshotImage {
    UIWindow *window = [self currentKeyWindow];
    if (!window) {
        return nil;
    }
    
    BOOL previewHidden = self.screenshotPreviewImageView.isHidden;
    self.screenshotPreviewImageView.hidden = YES;
    
    CGSize size = window.bounds.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        self.screenshotPreviewImageView.hidden = previewHidden;
        return nil;
    }
    
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = [UIScreen mainScreen].scale;
    format.opaque = window.opaque;
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        BOOL drawSuccess = [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
        if (!drawSuccess) {
            [window.layer renderInContext:rendererContext.CGContext];
        }
    }];
    self.screenshotPreviewImageView.hidden = previewHidden;
    
    return image;
}

- (void)showScreenshotPreviewWithImage:(UIImage *)image {
    UIWindow *window = [self currentKeyWindow];
    if (!window) {
        return;
    }
    
    UIImageView *imageView = self.screenshotPreviewImageView;
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 8.0;
        imageView.layer.borderWidth = 2.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowOpacity = 0.25;
        imageView.layer.shadowOffset = CGSizeMake(0, 2);
        imageView.layer.shadowRadius = 8.0;
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideScreenshotPreview)];
        [imageView addGestureRecognizer:tap];
        
        self.screenshotPreviewImageView = imageView;
    }
    
    if (imageView.superview != window) {
        [imageView removeFromSuperview];
        [window addSubview:imageView];
    }
    
    imageView.hidden = NO;
    imageView.alpha = 1.0;
    imageView.image = image;
    imageView.frame = [self screenshotPreviewFrameInWindow:window imageSize:image.size];
    [window bringSubviewToFront:imageView];
}

- (CGRect)screenshotPreviewFrameInWindow:(UIWindow *)window imageSize:(CGSize)imageSize {
    CGFloat margin = 16.0;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = window.safeAreaInsets;
    }
    
    CGSize windowSize = window.bounds.size;
    CGFloat maxWidth = MIN(120.0, windowSize.width * 0.32);
    CGFloat maxHeight = MIN(220.0, windowSize.height * 0.24);
    CGFloat imageRatio = imageSize.width > 0 ? imageSize.height / imageSize.width : 1.0;
    CGFloat width = maxWidth;
    CGFloat height = width * imageRatio;
    
    if (height > maxHeight) {
        height = maxHeight;
        width = height / MAX(imageRatio, 0.01);
    }
    
    CGFloat x = windowSize.width - safeAreaInsets.right - margin - width;
    CGFloat y = windowSize.height - safeAreaInsets.bottom - margin - height;
    
    return CGRectIntegral(CGRectMake(x, y, width, height));
}

- (void)hideScreenshotPreview {
    self.screenshotPreviewImageView.hidden = YES;
}

- (nullable UIWindow *)currentKeyWindow {
    UIWindow *delegateWindow = [UIApplication sharedApplication].delegate.window;
    if (delegateWindow) {
        return delegateWindow;
    }
    
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.isKeyWindow) {
            return window;
        }
    }
    
    return [UIApplication sharedApplication].windows.firstObject;
}

- (void)dealloc {
    [self stopMonitoring];
}

@end
