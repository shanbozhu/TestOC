//
//  PBServiceDispatch.m
//  BBAHomePage
//
//  Created by zhushanbo on 2020/2/28.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import "PBServiceDispatch.h"

@interface PBServiceDispatch ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSHashTable *> *servicesMap;

@end

@implementation PBServiceDispatch

- (instancetype)init {
    if (self = [super init]) {
        _servicesMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerServices:(NSArray<id> *)services protocol:(Protocol *)protocol {
    if (!protocol || !services || ![services isKindOfClass:[NSArray class]] || services.count == 0) {
        return;
    }
    NSString *protocolKey = NSStringFromProtocol(protocol);
    if (!protocolKey || ![protocolKey isKindOfClass:[NSString class]] || protocolKey.length == 0) {
        return;
    }
    @synchronized (self) {
        NSHashTable *servicesTable = [_servicesMap objectForKey:protocolKey];
        if (!servicesTable) {
            servicesTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
            [_servicesMap setObject:servicesTable forKey:protocolKey];
        }
        [services enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [servicesTable addObject:obj];
        }];
    }
}

#pragma mark - Public

- (void)registerService:(id)service protocol:(Protocol *)protocol {
    if (!protocol || !service) {
        return;
    }
    [self registerServices:@[service] protocol:protocol];
}

- (NSArray *)servicesForProtocol:(Protocol *)protocol {
    if (!protocol) {
        return nil;
    }
    NSArray *services = nil;
    @synchronized (self) {
        NSString *protocolKey = NSStringFromProtocol(protocol);
        services = [_servicesMap objectForKey:protocolKey].allObjects;
    }
    return services;
}

- (void)removeService:(id)service protocol:(Protocol *)protocol {
    if (!protocol || !service) {
        return;
    }
    @synchronized (self) {
        NSString *protocolKey = NSStringFromProtocol(protocol);
        NSHashTable *servicesTable = [_servicesMap objectForKey:protocolKey];
        if (servicesTable) {
            [servicesTable removeObject:service];
        }
    }
}

- (void)removeAllServicesForProtocol:(Protocol *)protocol {
    if (!protocol) {
        return;
    }
    @synchronized (self) {
        NSString *protocolKey = NSStringFromProtocol(protocol);
        [_servicesMap removeObjectForKey:protocolKey];
    }
}

@end
