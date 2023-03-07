//
//  PBServiceBridge.m
//  TestOC
//
//  Created by shanbo on 2023/3/6.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBServiceBridge.h"

@interface PBServiceBridge ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *serviceStore;

@end

@implementation PBServiceBridge

#pragma mark -

- (NSMutableDictionary<NSString *, id> *)serviceStore {
    if (!_serviceStore) {
        _serviceStore = [NSMutableDictionary new];
    }
    return _serviceStore;
}

#pragma mark -

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark -

+ (void)bindService:(id)service protocol:(Protocol *)protocol {
    if ([service conformsToProtocol:protocol]) {
        [[PBServiceBridge sharedInstance].serviceStore setValue:service
                                                         forKey:NSStringFromProtocol(protocol)];
    }
}

+ (id)serviceForProtocol:(Protocol *)protocol {
    return [[PBServiceBridge sharedInstance].serviceStore valueForKey:NSStringFromProtocol(protocol)];
}

@end
