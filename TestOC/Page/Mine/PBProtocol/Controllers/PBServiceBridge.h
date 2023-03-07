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

+ (void)bindService:(id)service protocol:(Protocol *)protocol;
+ (id)serviceForProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
