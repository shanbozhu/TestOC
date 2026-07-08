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
    
    CGSize size = window.bounds.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
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
    
    return image;
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
