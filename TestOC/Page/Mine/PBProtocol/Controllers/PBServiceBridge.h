//
//  PBServiceBridge.h
//  TestOC
//
//  Created by shanbo on 2023/3/6.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 一个类可以遵守多个协议,一个协议可以被多个类遵守
 */

@interface PBServiceBridge : NSObject

// 对象
+ (void)registerService:(id)service protocol:(Protocol *)protocol;
- (NSArray *)servicesForProtocol:(Protocol *)protocol;

// 类对象
+ (void)registerClassService:(Class)aClass protocol:(Protocol *)protocol;
+ (Class)classServiceForProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
