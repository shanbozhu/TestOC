//
//  BBAHomePageEventDispatch.m
//  BBAHomePage
//
//  Created by fanshuaifei on 2020/2/28.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import "BBAHomePageEventDispatch.h"

@interface BBAHomePageEventDispatch ()

@property (nonatomic) NSMutableDictionary <NSString *, NSHashTable *> *eventMap;

@end

@implementation BBAHomePageEventDispatch

- (instancetype)init {
    if (self = [super init]) {
        _eventMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerEventObject:(id)eventObject forService:(Protocol *)eventService {
    if (!eventService || !eventObject) {
        return;
    }
    [self registerEventObjects:@[eventObject] forService:eventService];
}

- (void)registerEventObjects:(NSArray<id> *)eventObjects forService:(Protocol *)eventService {
    if (!eventService || !eventObjects || ![eventObjects isKindOfClass:[NSArray class]] || eventObjects.count == 0) {
        return;
    }
    NSString *eventKey = NSStringFromProtocol(eventService);
    if (!eventKey || ![eventKey isKindOfClass:[NSString class]] || eventKey.length == 0) {
        return;
    }
    @synchronized (self) {
        NSHashTable *mapEventObjects = [_eventMap objectForKey:eventKey];
        if (!mapEventObjects) {
            mapEventObjects = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
            [_eventMap setObject:mapEventObjects forKey:eventKey];
        }
        [eventObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [mapEventObjects addObject:obj];
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
        eventObjects = [_eventMap objectForKey:eventKey].allObjects;
    }
    return eventObjects;
}

- (void)removeEventObject:(id)eventObject forService:(Protocol *)eventService {
    if (!eventService || !eventObject) {
        return;
    }
    @synchronized (self) {
        NSString *eventKey = NSStringFromProtocol(eventService);
        NSHashTable *eventObjects = [_eventMap objectForKey:eventKey];
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
        [_eventMap removeObjectForKey:eventKey];
    }
}

@end
