//
//  PBCrossAppUniqueDeviceIdentifierManager.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBCrossConfiguration.h"
#import "PBCrossIdentity.h"
#import "PBCrossAdRequestAdapter.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^PBCrossIdentityCompletion)(PBCrossIdentity * _Nullable identity, NSError * _Nullable error);

/// 身份发生更新（例如远端 ID 返回）时在主线程发送。
FOUNDATION_EXPORT NSNotificationName const PBCrossAppUniqueDeviceIdentifierDidUpdateNotification;

/// userInfo 中携带 PBCrossIdentity。
FOUNDATION_EXPORT NSString * const PBCrossAppUniqueDeviceIdentifierIdentityUserInfoKey;

/**
 *  跨 App 统一设备标识入口。
 *
 *  设计目标：
 *  1. 同 Team 的多个 App：通过共享 Keychain Access Group 共享同一个自建 UUID，App Group 可选；
 *  2. 不同公司/不同开发者的 App：通过 pb-xid-v1 设备属性指纹（相同字段集 + 相同盐值）得到同一个 ID；
 *  3. 需要中心化发号时：通过自建 ID 服务（CAID API 兼容协议）下发版本化 ID；
 *  4. 广告归因：用 PBCrossIdentityMatcher 对媒体回传的 ext.pb_cross_app 做匹配。
 *
 *  默认完全本地运行，不发起网络请求、不读取 IDFA、不弹 ATT 授权框。
 */
@interface PBCrossAppUniqueDeviceIdentifierManager : NSObject

+ (instancetype)sharedManager;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 当前配置的拷贝。
@property (nonatomic, copy, readonly) PBCrossConfiguration *configuration;

/**
 *  更新配置。配置校验失败时保持原配置不变。
 *  配置 appGroupIdentifier 时必须同时配置共享 keychainAccessGroup。
 *  示例：
 *    NSError *error = nil;
 *    [manager configureWithBlock:^(PBCrossConfiguration *config) {
 *        config.salt = @"your-ecosystem-salt";
 *        config.keychainAccessGroup = @"TEAMID.com.example.shared";
 *        config.appGroupIdentifier = @"group.com.example.shared";
 *    } error:&error];
 */
- (BOOL)configureWithBlock:(void (^)(PBCrossConfiguration *configuration))block
                     error:(NSError * _Nullable * _Nullable)error;

/// 异步加载身份。completion 在主线程回调；优先返回内存缓存。
/// Keychain 失败时返回不含共享 ID 的身份与 NSError，后续加载会重试。
/// 加载或等待回调期间配置/身份被更新时，返回 nil 与 PBCrossIdentifierErrorOperationCancelled。
/// 返回缓存与交付回调前均检查广告授权；撤回后移除明文 IDFA 和 idfa_md5。
- (void)loadIdentityWithCompletion:(nullable PBCrossIdentityCompletion)completion;

/// 同步加载身份（可能阻塞主线程约 0.5 秒，不发起远端请求）。建议仅在非主线程或启动早期使用。
/// 加载期间配置更新时使用新配置重试。
- (PBCrossIdentity *)identitySynchronously;

/// 已缓存的最近一次身份；尚未加载时为 nil。
@property (nonatomic, strong, readonly, nullable) PBCrossIdentity *cachedIdentity;

/// 强制重新采集设备属性并生成身份（仍只使用本地缓存的远端 ID）。
- (void)refreshIdentityWithCompletion:(nullable PBCrossIdentityCompletion)completion;

/// 请求远端自建 ID 服务。completion 在主线程回调；未启用/未同意隐私授权时返回错误。
- (void)resolveRemoteIdentityWithCompletion:(nullable PBCrossIdentityCompletion)completion;

/// 跨 App 共享的自建 ID。首次调用会生成并写入 Keychain，可选镜像到 App Group。
/// Keychain 不可用时返回空串，不生成替代身份；需要错误详情时使用异步加载接口。
@property (nonatomic, copy, readonly) NSString *sharedID;

/// 注入服务端下发的共享 ID；成功后使旧加载与远端请求失效，下次加载生效。
/// nil/空串移除服务端优先标记并保留最后有效 ID；失败返回 NO。
- (BOOL)setServerIssuedSharedID:(nullable NSString *)sharedID;

/// 生成广告请求适配器；无缓存身份时会同步加载。
- (PBCrossAdRequestAdapter *)adRequestAdapterWithContext:(nullable PBCrossAdRequestContext *)context;

/// 清空内存中的身份缓存（不会删除 Keychain/App Group 中的 ID）。
- (void)resetIdentityCache;

/// 清除已持久化的共享 ID、服务端 ID、远端缓存与请求计数。
/// 注意：会同时影响同一 Keychain Access Group / App Group 内的其他 App；下次加载会生成新的 UUID。
/// 兼容接口不返回删除错误；需要确认清理结果时使用 clearStoredIdentityWithError:。
- (void)clearStoredIdentity;

/// 清理并报告 Keychain 删除错误；失败时可能已完成部分清理，应处理错误后重试。
- (BOOL)clearStoredIdentityWithError:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
