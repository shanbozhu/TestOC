//
//  PBCycleTimerProxy.h
//  TestOC
//
//  Created by shanbo on 2022/4/28.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PBCycleTimerProxy;
@protocol PBCycleTimerProxyDelegate <NSObject>

- (void)cycleTimerProxy:(PBCycleTimerProxy *)timerProxy;

@end

@interface PBCycleTimerProxy : NSObject

@property (nonatomic, weak) id<PBCycleTimerProxyDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
