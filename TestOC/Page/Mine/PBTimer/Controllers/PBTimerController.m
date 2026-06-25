//
//  PBTimerController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTimerController.h"
#import "YYFPSLabel.h"

@interface PBTimerController ()

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, weak) NSTimer *scheduledTimer;
@property (nonatomic, strong) dispatch_source_t gcdTimer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation PBTimerController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 停止定时器
    [self.timer invalidate];
    
    // 停止定时器
    [self.scheduledTimer invalidate];
    
    // 停止定时器
    dispatch_source_cancel(self.gcdTimer);
    
    [self endTemporaryBackgroundTask];
}

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
    
    {
        // 方式一【不推荐】
        // 默认添加到 NSDefaultRunLoopMode
        NSTimer *scheduledTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scheduledTimerClick:) userInfo:nil repeats:YES];
        self.scheduledTimer = scheduledTimer;
    }
    
    {
        // 方式二【推荐】
        // UIScrollView滑动时执行的是UITrackingRunLoopMode，此时NSDefaultRunLoopMode被挂起
        // 要么同时将timer添加到UITrackingRunLoopMode和NSDefaultRunLoopMode
        // 要么直接将timer添加到NSRunLoopCommonModes
        // timer会持有target对象，NSRunLoop对象会持有timer
        // self.timer如果是strong，self会持有timer
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerClick:) userInfo:nil repeats:YES];
        //[[NSRunLoop mainRunLoop]addTimer:timer forMode:UITrackingRunLoopMode];
        //[[NSRunLoop mainRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
        self.timer = timer;
    }
    
    {
        // 方式三【推荐】
        __block int count = 60;
        
        dispatch_source_t gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        self.gcdTimer = gcdTimer;
        dispatch_source_set_timer(gcdTimer, dispatch_walltime(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), 1.0 * NSEC_PER_SEC, 0); // 从开始计时到延时1.0s后初次执行block
        dispatch_source_set_event_handler(gcdTimer, ^{
            if (count == 0) {
                dispatch_source_cancel(gcdTimer);
            }
            NSLog(@"方式三：count = %d, [NSThread currentThread] = %@", count, [NSThread currentThread]);
            
            count--;
        });
        
        dispatch_resume(gcdTimer);
    }
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
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithName:@"PBTimerControllerBackgroundTask"
                                                           expirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            NSLog(@"临时后台任务即将到期，结束后台任务");
            [self endTemporaryBackgroundTask];
        });
    }];
    
    if (self.backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        NSLog(@"申请临时后台任务失败");
        return;
    }
    
    NSLog(@"申请临时后台任务成功，backgroundTimeRemaining = %f", application.backgroundTimeRemaining);
}

- (void)endTemporaryBackgroundTask {
    if (self.backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        return;
    }
    
    UIBackgroundTaskIdentifier taskIdentifier = self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    
    [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
    NSLog(@"临时后台任务已结束");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 暂停定时器
    dispatch_suspend(self.gcdTimer);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 恢复定时器
    dispatch_resume(self.gcdTimer);
}

- (void)timerClick:(NSTimer *)timer {
    NSLog(@"方式二：timer添加到NSRunLoopCommonModes");
}

- (void)scheduledTimerClick:(NSTimer *)timer {
    NSLog(@"方式一：timer添加到NSDefaultRunLoopMode");
    NSLog(@"state = %ld, backgroundTimeRemaining = %f",
          (long)[UIApplication sharedApplication].applicationState,
          [UIApplication sharedApplication].backgroundTimeRemaining);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self endTemporaryBackgroundTask];
    
    NSLog(@"PBTimerController被释放了");
}

@end
