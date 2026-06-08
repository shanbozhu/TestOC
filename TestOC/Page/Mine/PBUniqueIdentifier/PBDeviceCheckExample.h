//
//  PBDeviceCheckExample.h
//  TestOC
//
//  Created by zhushanbo on 2026/6/8.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// DeviceCheck 工作流中的单个步骤结果
@interface PBDeviceCheckStepResult : NSObject

@property (nonatomic, copy) NSString *stepTitle;
@property (nonatomic, copy) NSString *stepDetail;
@property (nonatomic, assign, getter=isSuccess) BOOL success;

@end

/**
 DeviceCheck 方案示例
 
 工作流（与 Apple 官方设计一致）：
 ┌─────────┐    Token     ┌──────────┐   validate/query   ┌─────────────────────────┐
 │   App   │ ──────────> │ 开发者服务器 │ ─────────────────> │ Apple DeviceCheck Server │
 └─────────┘              └──────────┘                    └─────────────────────────┘
                                                                    │
                                                         Apple 判断「是否同一台设备」
                                                         但不把设备标识直接返回给开发者
 
 开发者能拿到的是：两台设备上的两个 bit 状态（0/1），用于风控、黑白名单等场景。
 */
@interface PBDeviceCheckExample : NSObject

/// 逐步执行 DeviceCheck 完整流程（客户端真实生成 Token + 服务端逻辑模拟演示）
+ (void)runWorkflowExampleWithProgress:(void (^)(PBDeviceCheckStepResult *result))progress
                            completion:(void (^)(NSArray<PBDeviceCheckStepResult *> *allSteps, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
