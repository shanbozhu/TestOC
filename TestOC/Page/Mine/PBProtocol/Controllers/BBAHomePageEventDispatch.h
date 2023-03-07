//
//  BBAHomePageEventDispatch.h
//  BBAHomePage
//
//  Created by fanshuaifei on 2020/2/28.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 业务方自定义实现的返回唯一ID的协议，为了实现一对一广播消息(用customIdentity 区分具体业务对象)
@protocol BBAHomePageEventDispatchEventObjectCustomProtocol <NSObject>

@optional

/// 返回自定义标识
- (NSString *)customIdentity;

@end

/// 首页事件分发服务协议，由其它组件注册，首页发生该事件或达到该状态后，针对注册的所有相关协议组件进行分发
@interface BBAHomePageEventDispatch : NSObject

#ifdef __BAIDULITE
/// 移除所有事件服务的事件对象
- (void)removeAllEventObjects;
#endif

/// 注册事件
/// @param eventObject 事件对象，注册完成后不会影响 eventObject 的生命周期
/// @param eventService 事件服务，即 eventObject 实现的事件协议
- (void)registerEventObject:(id<BBAHomePageEventDispatchEventObjectCustomProtocol>)eventObject forService:(Protocol *)eventService;

/// 注册事件
/// @param eventObjects 事件对象数组，注册完成后不会影响 eventObject 的生命周期
/// @param eventService 事件服务，即 eventObject 实现的事件协议
- (void)registerEventObjects:(NSArray<id<BBAHomePageEventDispatchEventObjectCustomProtocol>> *)eventObjects forService:(Protocol *)eventService;

/// 移除事件对象
/// @param eventObject  事件对象
/// @param eventService 事件服务，即 eventObject 实现的事件协议
- (void)removeEventObject:(id)eventObject forService:(Protocol *)eventService;

/// 移除所有事件对象
/// @param eventService 事件服务
- (void)removeAllEventObjectsForService:(Protocol *)eventService;

/// 获取所有事件对象
/// @param eventService 事件服务
- (NSArray *)eventObjectsForService:(Protocol *)eventService;

/// 获取第一个事件对象
/// @param eventService 事件服务
- (id)firstEventObjectForService:(Protocol *)eventService;

@end

NS_ASSUME_NONNULL_END
