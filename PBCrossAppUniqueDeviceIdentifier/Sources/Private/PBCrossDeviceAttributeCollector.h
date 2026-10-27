//
//  PBCrossDeviceAttributeCollector.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBCrossConfiguration;
@class PBCrossDeviceAttributes;

NS_ASSUME_NONNULL_BEGIN

/// 采集 CAID 兼容字段与扩展设备属性。
@interface PBCrossDeviceAttributeCollector : NSObject

/// 同步采集。UIKit 相关字段会切到主线程读取；运营商读取最多等待 0.5 秒。
+ (PBCrossDeviceAttributes *)collectAttributesWithConfiguration:(PBCrossConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
