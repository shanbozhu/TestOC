//
//  PBBackgroundTaskController.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/24.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBBackgroundTaskController.h"

@interface PBBackgroundTaskController ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation PBBackgroundTaskController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self beginTemporaryBackgroundTask];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self endTemporaryBackgroundTask];
}

- (void)beginTemporaryBackgroundTask {
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        return;
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    __weak typeof(self) weakSelf = self;
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithName:@"com.testoc.shortTask"
                                                           expirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) {
                return;
            }
            
            NSLog(@"后台时间即将耗尽，结束任务");
            [self endTemporaryBackgroundTask];
        });
    }];
    
    if (self.backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        NSLog(@"申请后台任务失败");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"开始后台短任务");
        
        for (NSInteger i = 0; i < 30; i++) {
            NSLog(@"后台执行中：%ld, remaining = %f",
                  (long)i,
                  application.backgroundTimeRemaining);
            [NSThread sleepForTimeInterval:1.0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) {
                return;
            }
            
            NSLog(@"后台短任务完成，主动结束");
            [self endTemporaryBackgroundTask];
        });
    });
}

- (void)endTemporaryBackgroundTask {
    if (self.backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        return;
    }
    
    UIBackgroundTaskIdentifier taskIdentifier = self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    
    [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
    NSLog(@"后台任务已结束");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self endTemporaryBackgroundTask];
}

@end
