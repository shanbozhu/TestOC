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
@synthesize provideData=_provideData;

+ (void)load {
    [PBServiceBridge bindService:[self new]
                        protocol:@protocol(PBServiceProtocol)];
}

- (NSString *)provideData {
    return @"PBService provideData";
}

- (void)doSomething {
    NSLog(@"PBService doSomething");
}

@end
