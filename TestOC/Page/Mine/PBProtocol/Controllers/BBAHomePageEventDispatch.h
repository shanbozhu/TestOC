//
//  BBAHomePageEventDispatch.h
//  BBAHomePage
//
//  Created by fanshuaifei on 2020/2/28.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 首页事件分发服务协议，由其它组件注册，首页发生该事件或达到该状态后，针对注册的所有相关协议组件进行分发
@interface BBAHomePageEventDispatch : NSObject

/// 注册事件
/// @param service 事件对象，注册完成后不会影响 eventObject 的生命周期
/// @param protocol 事件服务，即 eventObject 实现的事件协议
- (void)registerService:(id)service protocol:(Protocol *)protocol;

/// 获取所有事件对象
/// @param protocol 事件服务
- (NSArray *)servicesForProtocol:(Protocol *)protocol;

/// 移除事件对象
/// @param service  事件对象
/// @param protocol 事件服务，即 service 实现的事件协议
- (void)removeService:(id)service protocol:(Protocol *)protocol;

/// 移除所有事件对象
/// @param protocol 事件服务
- (void)removeAllServicesForProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
