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
FOUNDATION_EXPORT NSString * const PBScreenshotMonitorScreenshotDateKey;
FOUNDATION_EXPORT NSString * const PBScreenshotMonitorApplicationStateKey;
FOUNDATION_EXPORT NSString * const PBScreenshotMonitorScreenshotImageKey;

@interface PBScreenshotMonitor : NSObject

@property (nonatomic, assign, readonly, getter=isMonitoring) BOOL monitoring;

+ (instancetype)sharedMonitor;

- (void)startMonitoring;
- (void)stopMonitoring;
- (nullable UIImage *)currentWindowSnapshotImage;

@end

NS_ASSUME_NONNULL_END
