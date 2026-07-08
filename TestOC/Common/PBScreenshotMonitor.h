//
//  PBScreenshotMonitor.h
//  TestOC
//
//  Created by Codex on 2026/7/8.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const PBScreenshotMonitorDidTakeScreenshotNotification;
FOUNDATION_EXPORT NSNotificationName const PBScreenshotMonitorScreenCapturedDidChangeNotification;
FOUNDATION_EXPORT NSString * const PBScreenshotMonitorScreenshotDateKey;
FOUNDATION_EXPORT NSString * const PBScreenshotMonitorApplicationStateKey;
FOUNDATION_EXPORT NSString * const PBScreenshotMonitorScreenshotImageKey;
FOUNDATION_EXPORT NSString * const PBScreenshotMonitorScreenCapturedKey;

@interface PBScreenshotMonitor : NSObject

@property (nonatomic, assign, readonly, getter=isMonitoring) BOOL monitoring;
@property (nonatomic, assign, readonly, getter=isScreenCaptured) BOOL screenCaptured;

+ (instancetype)sharedMonitor;

- (void)startMonitoring;
- (void)stopMonitoring;
- (nullable UIImage *)currentWindowSnapshotImage;

@end

NS_ASSUME_NONNULL_END
