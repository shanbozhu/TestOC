//
//  PBGCDTimerManager.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/1/5.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBGCDTimer : NSObject

@end

@interface PBGCDTimerManager : NSObject

+ (id)sharedManager;

- (void)gcdTimerManagerWithName:(NSString *)timerName andTimeInterval:(NSTimeInterval)timeInterval andDelaySecs:(float)delaySecs andQueue:(dispatch_queue_t)queue andRepeats:(BOOL)repeats andAction:(dispatch_block_t)action;

- (void)startTimer:(NSString *)timerName; // 开始定时器
- (void)suspendTimer:(NSString *)timerName; // 暂停定时器
- (void)resumeTimer:(NSString *)timerName; // 恢复定时器
- (void)cancelTimerWithName:(NSString *)timerName; // 停止(取消)定时器

@end
