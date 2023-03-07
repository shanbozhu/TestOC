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
/// @param eventObject 事件对象，注册完成后不会影响 eventObject 的生命周期
/// @param eventService 事件服务，即 eventObject 实现的事件协议
- (void)registerEventObject:(id)eventObject forService:(Protocol *)eventService;

/// 获取所有事件对象
/// @param eventService 事件服务
- (NSArray *)eventObjectsForService:(Protocol *)eventService;

/// 移除事件对象
/// @param eventObject  事件对象
/// @param eventService 事件服务，即 eventObject 实现的事件协议
- (void)removeEventObject:(id)eventObject forService:(Protocol *)eventService;

/// 移除所有事件对象
/// @param eventService 事件服务
- (void)removeAllEventObjectsForService:(Protocol *)eventService;

@end

NS_ASSUME_NONNULL_END
