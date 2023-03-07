//
//  PBServiceBridge.m
//  TestOC
//
//  Created by shanbo on 2023/3/6.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBServiceBridge.h"
#import "PBServiceDispatch.h"

@interface PBServiceBridge ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *classServicesMap;

@property (nonatomic, strong) PBServiceDispatch *serviceDispatch;

@end

@implementation PBServiceBridge

#pragma mark -

- (NSMutableDictionary<NSString *, NSString *> *)classServicesMap {
    if (!_classServicesMap) {
        _classServicesMap = [NSMutableDictionary dictionary];
    }
    return _classServicesMap;
}

#pragma mark -

+ (instancetype)sharedInstance {
    static PBServiceBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        
        sharedInstance.serviceDispatch = [[PBServiceDispatch alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public

+ (void)registerService:(id)service protocol:(Protocol *)protocol {
    if ([service conformsToProtocol:protocol]) {
        [[PBServiceBridge sharedInstance].serviceDispatch registerService:service protocol:protocol];
    }
}

- (NSArray *)servicesForProtocol:(Protocol *)protocol {
    return [[PBServiceBridge sharedInstance].serviceDispatch servicesForProtocol:protocol];
}

+ (void)registerClassService:(Class)aClass protocol:(Protocol *)protocol {
    if ([aClass conformsToProtocol:protocol]) {
        [[PBServiceBridge sharedInstance].classServicesMap setObject:NSStringFromClass([aClass class]) forKey:NSStringFromProtocol(protocol)];
    }
}

+ (Class)classServiceForProtocol:(Protocol *)protocol {
    NSString *aClass = [[PBServiceBridge sharedInstance].classServicesMap objectForKey:NSStringFromProtocol(protocol)];
    if (aClass && aClass.length > 0) {
        return NSClassFromString(aClass);
    }
    return nil;
}

@end
