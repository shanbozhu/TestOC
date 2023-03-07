//
//  PBServiceBridge.h
//  TestOC
//
//  Created by shanbo on 2023/3/6.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBServiceBridge : NSObject

// 对象
+ (void)registerService:(id)service protocol:(Protocol *)protocol;
+ (id)serviceForProtocol:(Protocol *)protocol;

// 类对象
+ (void)registerClassService:(Class)aClass protocol:(Protocol *)protocol;
+ (Class)classServiceForProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
