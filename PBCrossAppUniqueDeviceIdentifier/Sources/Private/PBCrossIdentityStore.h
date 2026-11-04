//
//  PBCrossIdentityStore.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBCrossConfiguration;

NS_ASSUME_NONNULL_BEGIN

/// Keychain + App Group 持久化。所有方法线程安全。
@interface PBCrossIdentityStore : NSObject

- (instancetype)initWithConfiguration:(PBCrossConfiguration *)configuration;

@property (nonatomic, copy, readonly) PBCrossConfiguration *configuration;

/// 读取跨 App 自建 ID；仅 Keychain 确认无记录且 create 为 YES 时创建。
/// 读取/写入失败时返回空串并报告错误，不切换存储或返回未持久化的候选值。
/// @param serverIssued 输出是否为服务端下发（setServerIssuedSharedID）。
- (NSString *)sharedIDCreatingIfNeeded:(BOOL)create
                        serverIssued:(nullable BOOL *)serverIssued
                               error:(NSError * _Nullable * _Nullable)error;

/// 写入/清除服务端下发的共享 ID。sharedID 为空时仅清除"服务端下发"标记。
- (BOOL)setServerIssuedSharedID:(nullable NSString *)sharedID;

/// 远端解析结果缓存（NSDictionary，包含 identifiers / resolved_at 等）。
- (nullable NSDictionary<NSString *, id> *)remoteCache;
- (void)setRemoteCache:(nullable NSDictionary<NSString *, id> *)cache;

/// 请求计数（按本地日期）；未超限时自增并返回 YES。
- (BOOL)registerRemoteRequestIfAllowed:(NSUInteger)dailyLimit;

/// 记录本次 systemUpdateTime，返回上一次的 systemUpdateTime。
- (NSString *)updateSystemUpdateTimeHistoryWithCurrentValue:(nullable NSString *)currentValue;

/// 清除当前 Keychain 命名空间内的身份、远端缓存/请求计数与系统更新时间历史。
/// 注意：会同时影响同一 Keychain Access Group / App Group 内的其他 App。
- (void)clearStoredIdentity;
- (BOOL)clearStoredIdentityWithError:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
