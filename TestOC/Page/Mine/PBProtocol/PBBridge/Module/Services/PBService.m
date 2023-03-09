//
//  PBService.m
//  TestOC
//
//  Created by shanbo on 2023/3/7.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBService.h"
#import "PBServiceBridge.h"

__attribute__((constructor))
static void registerClassService(void) {
    NSLog(@"2 - __attribute__((constructor))");
    // 注册服务类对象
    [PBServiceBridge registerClassService:[PBService class]
                                 protocol:@protocol(PBServiceProtocol)];
}

@implementation PBService

+ (void)load {
    NSLog(@"1 - load");
}

+ (void)doSomething {
    NSLog(@"PBService +doSomething");
}

#pragma mark -

- (void)doSomething {
    NSLog(@"PBService -doSomething");
}

@end
