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
 一个类可以遵守多个协议，一个协议可以被多个类遵守
 */

@interface PBServiceBridge : NSObject

/// 注册服务对象
/// @param service  服务对象，注册完成后不会影响 service 的生命周期
/// @param protocol 服务对象遵守的协议
+ (void)registerService:(id)service protocol:(Protocol *)protocol;

/// 获取所有服务对象
/// @param protocol 服务对象遵守的协议
/// @return         所有遵守该协议的服务对象
+ (NSArray *)servicesForProtocol:(Protocol *)protocol;


//  服务类对象也可以存储多个，可以将类对象转化为NSString字符串存储，但是一般情况下，服务类对象只存储一个，与协议一一对应
/// 注册服务类对象
/// @param aClass   服务类对象
/// @param protocol 服务类对象遵守的协议
+ (void)registerClassService:(Class)aClass protocol:(Protocol *)protocol;

/// 获取服务类对象
/// @param protocol 服务类对象遵守的协议
/// @return         遵守该协议的服务类对象
+ (Class)classServiceForProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
