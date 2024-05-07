//
//  PBGCDTimerManager.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/1/5.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBGCDTimerManager.h"

@interface PBGCDTimer ()

@property (nonatomic, strong) dispatch_block_t action;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, copy) NSString *timerName;
@property (nonatomic, strong) NSArray *actionArr;
@property (nonatomic, assign) BOOL repeats;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) float delaySecs;
@property (nonatomic, assign) BOOL isRunning;

@end

@implementation PBGCDTimer

- (instancetype)initWithName:(NSString *)timerName andTimeInterval:(NSTimeInterval)timeInterval andDelaySecs:(float)delaySecs andQueue:(dispatch_queue_t)queue andRepeats:(BOOL)repeats andAction:(dispatch_block_t)action {
    if (self = [super init]) {
        self.action = action;
        self.timerName = timerName;
        self.repeats = repeats;
        self.timeInterval = timeInterval;
        self.isRunning = NO;
        
        NSString *queueName = [NSString stringWithFormat:@"PBGCDTimer.%p", self];
        self.queue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.queue, queue);
        
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:action];
        self.actionArr = arr;
    }
    return self;
}

- (void)addActionBlock:(dispatch_block_t)action {
    NSMutableArray *arr = [self.actionArr mutableCopy];
    [arr removeAllObjects];
    [arr addObject:action];
}

@end

@interface PBGCDTimerManager ()

@property (nonatomic, strong) NSMutableDictionary *timerDict;
@property (nonatomic, strong) NSMutableDictionary *gcdTimerDict;

@end

@implementation PBGCDTimerManager

- (void)gcdTimerManagerWithName:(NSString *)timerName andTimeInterval:(NSTimeInterval)timeInterval andDelaySecs:(float)delaySecs andQueue:(dispatch_queue_t)queue andRepeats:(BOOL)repeats andAction:(dispatch_block_t)action {
    PBGCDTimer *gcdTimer = self.gcdTimerDict[timerName];
    if (gcdTimer != nil) {
        return;
    }
    
    [self addGCDTimerManagerWithName:timerName andTimeInterval:timeInterval andDelaySecs:delaySecs andQueue:queue andRepeats:repeats andAction:action];
}

- (void)addGCDTimerManagerWithName:(NSString *)timerName andTimeInterval:(NSTimeInterval)timeInterval andDelaySecs:(float)delaySecs andQueue:(dispatch_queue_t)queue andRepeats:(BOOL)repeats andAction:(dispatch_block_t)action {
    if (!queue) {
        queue = dispatch_get_global_queue(0, 0);
    }
    
    PBGCDTimer *gcdTimer = self.gcdTimerDict[timerName];
    if (!gcdTimer) {
        gcdTimer = [[PBGCDTimer alloc]initWithName:timerName andTimeInterval:timeInterval andDelaySecs:delaySecs andQueue:queue andRepeats:repeats andAction:action];
        self.gcdTimerDict[timerName] = gcdTimer;
    } else {
        [gcdTimer addActionBlock:action];
        gcdTimer.timeInterval = timeInterval;
        gcdTimer.delaySecs = delaySecs;
        gcdTimer.queue = queue;
        gcdTimer.repeats = repeats;
    }
    
    dispatch_source_t timer = self.timerDict[timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, gcdTimer.queue);
        self.timerDict[timerName] = timer;
    }
}

- (void)startTimer:(NSString *)timerName {
    PBGCDTimer *gcdTimer = self.gcdTimerDict[timerName];
    if (gcdTimer != nil && gcdTimer.isRunning == NO) {
        dispatch_source_t timer = self.timerDict[timerName];
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, gcdTimer.delaySecs * NSEC_PER_SEC), gcdTimer.timeInterval * NSEC_PER_SEC, 0);
        __weak typeof(self)weakSelf = self;
        dispatch_source_set_event_handler(timer, ^{
            gcdTimer.action();
            if (gcdTimer.repeats == NO) {
                [weakSelf cancelTimerWithName:timerName];
            }
        });
        [self resumeTimer:timerName];
    }
}

- (void)resumeTimer:(NSString *)timerName {
    dispatch_source_t timer = self.timerDict[timerName];
    if (!timer) {
        return;
    }
    
    PBGCDTimer *gcdTimer = self.gcdTimerDict[timerName];
    if (gcdTimer.isRunning == NO) {
        dispatch_resume(timer);
        gcdTimer.isRunning = YES;
    }
}

- (void)cancelTimerWithName:(NSString *)timerName {
    dispatch_source_t timer = self.timerDict[timerName];
    if (!timer) {
        return;
    }
    
    PBGCDTimer *gcdTimer = self.gcdTimerDict[timerName];
    if (gcdTimer.isRunning == NO) {
        [self resumeTimer:timerName];
    }
    dispatch_source_cancel(timer);
    [self.timerDict removeObjectForKey:timerName];
    [self.gcdTimerDict removeObjectForKey:timerName];
}

- (void)suspendTimer:(NSString *)timerName {
    dispatch_source_t timer = self.timerDict[timerName];
    if (!timer) {
        return;
    }
    
    PBGCDTimer *gcdTimer = self.gcdTimerDict[timerName];
    if (gcdTimer.isRunning == YES) {
        dispatch_suspend(timer);
        gcdTimer.isRunning = NO;
    }
}

- (NSMutableDictionary *)gcdTimerDict {
    if (!_gcdTimerDict) {
        _gcdTimerDict = [NSMutableDictionary dictionary];
    }
    return _gcdTimerDict;
}

- (NSMutableDictionary *)timerDict {
    if (!_timerDict) {
        _timerDict = [NSMutableDictionary dictionary];
    }
    return _timerDict;
}

+ (id)sharedManager {
    static PBGCDTimerManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.timerDict = [NSMutableDictionary dictionary];
    }
    return self;
}

@end
