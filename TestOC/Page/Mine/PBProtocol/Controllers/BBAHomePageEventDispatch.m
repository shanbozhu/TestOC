//
//  BBAHomePageEventDispatch.m
//  BBAHomePage
//
//  Created by fanshuaifei on 2020/2/28.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import "BBAHomePageEventDispatch.h"

@interface BBAHomePageEventDispatch ()

@property (nonatomic) NSMutableDictionary <NSString *, NSHashTable *> *servicesMap;

@end

@implementation BBAHomePageEventDispatch

- (instancetype)init {
    if (self = [super init]) {
        _servicesMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerService:(id)service protocol:(Protocol *)protocol {
    if (!service || !protocol) {
        return;
    }
    [self registerServices:@[service] protocol:protocol];
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

- (NSArray *)eventObjectsForService:(Protocol *)eventService {
    if (!eventService) {
        return nil;
    }
    NSArray *eventObjects = nil;
    @synchronized (self) {
        NSString *eventKey = NSStringFromProtocol(eventService);
        eventObjects = [_servicesMap objectForKey:eventKey].allObjects;
    }
    return eventObjects;
}

- (void)removeEventObject:(id)eventObject forService:(Protocol *)eventService {
    if (!eventService || !eventObject) {
        return;
    }
    @synchronized (self) {
        NSString *eventKey = NSStringFromProtocol(eventService);
        NSHashTable *eventObjects = [_servicesMap objectForKey:eventKey];
        if (eventObjects) {
            [eventObjects removeObject:eventObject];
        }
    }
}

- (void)removeAllEventObjectsForService:(Protocol *)eventService {
    if (!eventService) {
        return;
    }
    @synchronized (self) {
        NSString *eventKey = NSStringFromProtocol(eventService);
        [_servicesMap removeObjectForKey:eventKey];
    }
}

@end
