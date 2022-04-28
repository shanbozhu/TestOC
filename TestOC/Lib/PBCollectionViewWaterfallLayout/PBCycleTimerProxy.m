//
//  PBCycleTimerProxy.m
//  TestOC
//
//  Created by shanbo on 2022/4/28.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCycleTimerProxy.h"

@implementation PBCycleTimerProxy

- (void)showNext {
    if ([self.delegate respondsToSelector:@selector(cycleTimerProxy:)]) {
        [self.delegate cycleTimerProxy:self];
    }
}

- (void)dealloc {
    NSLog(@"PBCycleTimerProxy对象被释放了");
}

@end
