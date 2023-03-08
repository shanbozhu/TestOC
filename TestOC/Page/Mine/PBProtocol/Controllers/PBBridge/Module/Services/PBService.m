//
//  PBService.m
//  TestOC
//
//  Created by shanbo on 2023/3/7.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBService.h"
#import "PBServiceBridge.h"

@implementation PBService

+ (void)load {
    // 注册服务类对象
    [PBServiceBridge registerClassService:self
                                 protocol:@protocol(PBServiceProtocol)];
}

+ (void)doSomething {
    NSLog(@"PBService +doSomething");
}

#pragma mark -

- (void)doSomething {
    NSLog(@"PBService -doSomething");
}

@end
