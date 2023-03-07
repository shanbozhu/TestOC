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
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *classServiceStore;

@end

@implementation PBServiceBridge

#pragma mark -

- (NSMutableDictionary<NSString *, id> *)serviceStore {
    if (!_serviceStore) {
        _serviceStore = [NSMutableDictionary dictionary];
    }
    return _serviceStore;
}

- (NSMutableDictionary<NSString *, id> *)classServiceStore {
    if (!_classServiceStore) {
        _classServiceStore = [NSMutableDictionary dictionary];
    }
    return _classServiceStore;
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

+ (void)registerService:(id)service protocol:(Protocol *)protocol {
    if ([service conformsToProtocol:protocol]) {
        [[PBServiceBridge sharedInstance].serviceStore setValue:service
                                                         forKey:NSStringFromProtocol(protocol)];
    }
}

+ (id)serviceForProtocol:(Protocol *)protocol {
    return [[PBServiceBridge sharedInstance].serviceStore valueForKey:NSStringFromProtocol(protocol)];
}

#pragma mark -
+ (void)registerClassService:(Class)aClass protocol:(Protocol *)protocol {
    if ([aClass conformsToProtocol:protocol]) {
        [[PBServiceBridge sharedInstance].classServiceStore setValue:aClass forKey:NSStringFromProtocol(protocol)];
    }
}

+ (Class)classServiceForProtocol:(Protocol *)protocol {
    return [[PBServiceBridge sharedInstance].classServiceStore valueForKey:NSStringFromProtocol(protocol)];;
}

@end
