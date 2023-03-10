//
//  PBServiceDispatch.h
//  BBAHomePage
//
//  Created by zhushanbo on 2020/2/28.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBServiceDispatch : NSObject

/// 注册服务对象
/// @param service  服务对象,注册完成后不会影响 service 的生命周期
/// @param protocol 服务对象遵守的协议
- (void)registerService:(id)service protocol:(Protocol *)protocol;

/// 获取所有服务对象
/// @param protocol 服务对象遵守的协议
/// @return         所有遵守该协议的服务对象
- (NSArray *)servicesForProtocol:(Protocol *)protocol;

/// 移除服务对象
/// @param service  服务对象
/// @param protocol 服务对象遵守的协议
- (void)removeService:(id)service protocol:(Protocol *)protocol;

/// 移除所有服务对象
/// @param protocol 服务对象遵守的协议
- (void)removeAllServicesForProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
