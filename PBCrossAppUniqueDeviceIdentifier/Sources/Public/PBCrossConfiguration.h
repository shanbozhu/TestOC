//
//  PBCrossConfiguration.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBCrossDeviceAttributes.h"

NS_ASSUME_NONNULL_BEGIN

/// 错误域。本地配置、生成、匹配与远端解析错误共用。
FOUNDATION_EXPORT NSErrorDomain const PBCrossIdentifierErrorDomain;

/// 本地错误码。
typedef NS_ERROR_ENUM(PBCrossIdentifierErrorDomain, PBCrossIdentifierErrorCode) {
    PBCrossIdentifierErrorInvalidConfiguration = 1,
    PBCrossIdentifierErrorIdentityUnavailable = 2,
};

/// 远端自建 ID 服务错误码。
typedef NS_ERROR_ENUM(PBCrossIdentifierErrorDomain, PBCrossRemoteErrorCode) {
    PBCrossRemoteErrorNotConfigured = 1001,
    PBCrossRemoteErrorConsentRequired = 1002,
    PBCrossRemoteErrorDailyLimitExceeded = 1003,
    PBCrossRemoteErrorMissingDeviceAttributes = 1004,
    PBCrossRemoteErrorInvalidPublicKey = 1005,
    PBCrossRemoteErrorEncryptionFailed = 1006,
    PBCrossRemoteErrorNetwork = 1007,
    PBCrossRemoteErrorInvalidResponse = 1008,
    PBCrossRemoteErrorDecryptionFailed = 1009,
    PBCrossRemoteErrorServerCode = 1010,
    PBCrossRemoteErrorInvalidEndpoint = 1011,
};

/// 指纹算法标识，会写入 id 扩展信息用于版本协商。
FOUNDATION_EXPORT NSString * const PBCrossIdentifierAlgorithmName;

/// SDK 版本号。
FOUNDATION_EXPORT NSString * const PBCrossAppUniqueDeviceIdentifierVersion;

/// 默认盐值。跨公司合作时必须使用同一个盐值（建议由合作方约定后覆盖）。
FOUNDATION_EXPORT NSString * const PBCrossDefaultSalt;

/// 默认 Keychain Service。
FOUNDATION_EXPORT NSString * const PBCrossDefaultKeychainService;

/**
 *  指纹算法版本。
 *
 *  一个版本 = 版本号 + 参与计算的属性集合 + 可选独立盐值。
 *  跨公司识别的关键在于所有 App 使用完全相同的版本配置；升级算法时应保留旧版本，
 *  以当前版本 + 上一版本的双 ID 形式同时上报，方便广告归因时任一命中即可。
 */
@interface PBCrossIdentifierVersion : NSObject <NSCopying>

+ (instancetype)versionWithName:(NSString *)name
                   attributeKeys:(NSArray<PBCrossAttributeKey> *)attributeKeys;

+ (instancetype)versionWithName:(NSString *)name
                   attributeKeys:(NSArray<PBCrossAttributeKey> *)attributeKeys
                            salt:(nullable NSString *)salt;

/**
 *  默认当前版本（20261001）。
 *
 *  字段集包含启动时间、设备名称 MD5、设备初始化时间、系统更新时间、mntId 等设备级熵源，
 *  排除系统版本、时区、语言、运营商等易变字段。该版本在单次开机内稳定、跨 App 可复现；
 *  重启后启动时间变化，ID 会轮换（与 CAID 的行为一致）。需要重启后仍不变的自建 ID 时，
 *  请使用 Keychain/App Group 共享 UUID 或服务端下发 ID。
 */
+ (instancetype)defaultVersion;

/**
 *  上一版本 / CAID 兼容版本（20260301）。
 *
 *  字段集与 CAID API 文档 5.1 节的 14 个字段完全一致，便于与历史 CAID 数据、
 *  已接入的合作方做兼容匹配。启动时间变化会导致该版本 ID 在重启后改变。
 */
+ (instancetype)compatibilityVersion;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSArray<PBCrossAttributeKey> *attributeKeys;
@property (nonatomic, copy, readonly, nullable) NSString *salt;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 *  远端自建 ID 服务配置。
 *
 *  协议与 CAID API v1.15 保持一致：
 *  - POST JSON: { "dev_id": "...", "encrypted_device_info": "..." }
 *  - encrypted_device_info：14 个设备字段 JSON 后使用服务端公钥 RSA/PKCS#1 加密并 Base64；
 *  - 响应 data 字段：使用同一公钥解密后得到 [{ "version": "...", "caid": "..." }]。
 *
 *  注意：CAID 官方服务已下线（拼多多规范 0.0.33，2026.07.03），默认不启用远端；如启用，
 *  请指向自建服务并完成隐私合规评估。SDK 默认本地生成 ID，不产生任何网络请求。
 */
@interface PBCrossRemoteConfiguration : NSObject <NSCopying>

/// 是否启用远端解析，默认 NO。
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/// 服务地址，必须为 HTTPS（调试时可配合 allowsInsecureHTTP）。
@property (nonatomic, copy, nullable) NSURL *endpointURL;

/// 分配的开发方 ID，对应协议中的 dev_id。
@property (nonatomic, copy, nullable) NSString *developerID;

/// 服务端公钥。支持 X.509 证书（Base64/PEM）、PKCS#1 公钥（Base64/PEM）、SPKI 公钥（PEM）。
@property (nonatomic, copy, nullable) NSString *publicKey;

/// 请求超时，默认 10 秒。
@property (nonatomic, assign) NSTimeInterval requestTimeout;

/// 远端结果缓存时长，默认 24 小时（CAID 文档要求不超过 24 小时）。
@property (nonatomic, assign) NSTimeInterval cacheTimeToLive;

/// 同一设备每天最多请求次数，默认 5 次（CAID 文档要求平均每天不超过 5 次）。
@property (nonatomic, assign) NSUInteger dailyRequestLimit;

/// 是否需要用户已同意隐私政策/设备信息上报，默认 YES。
@property (nonatomic, assign) BOOL requiresUserConsent;

/// 用户是否已同意。默认 NO；仅在 requiresUserConsent 为 YES 时生效。
@property (nonatomic, assign, getter=hasUserConsent) BOOL userConsentGranted;

/// 是否允许 HTTP（仅调试，默认 NO）。
@property (nonatomic, assign) BOOL allowsInsecureHTTP;

/// 静态配置是否完整。
@property (nonatomic, assign, readonly, getter=isConfigured) BOOL configured;

/// 校验静态配置。
- (BOOL)validateWithError:(NSError * _Nullable * _Nullable)error;

@end

/**
 *  SDK 全局配置。通过 PBCrossAppUniqueDeviceIdentifierManager 的 configure 方法设置。
 */
@interface PBCrossConfiguration : NSObject <NSCopying>

/// 指纹盐值，默认 PBCrossDefaultSalt。合作方必须一致。
@property (nonatomic, copy) NSString *salt;

/// 支持的算法版本，默认 [defaultVersion, compatibilityVersion]，顺序即当前版本、上一版本。
@property (nonatomic, copy) NSArray<PBCrossIdentifierVersion *> *supportedVersions;

/// 共享 Keychain Access Group。同 Team 的多个 App 配置相同值后，可共享自建 UUID。
@property (nonatomic, copy, nullable) NSString *keychainAccessGroup;

/// Keychain Service，默认 PBCrossDefaultKeychainService。
@property (nonatomic, copy) NSString *keychainService;

/// App Group，同 Team 的多个 App 配置相同值后，可通过共享容器传递自建 ID 与远端结果。
@property (nonatomic, copy, nullable) NSString *appGroupIdentifier;

/// 是否采集设备名称的 MD5（默认 YES；当前版本与 CAID 兼容版本都使用）。
@property (nonatomic, assign) BOOL collectsDeviceName;

/// 是否采集运营商信息（默认 YES）。
@property (nonatomic, assign) BOOL collectsCarrierInformation;

/// 是否允许读取 IDFA（默认 NO）。开启后仍要求 ATT 已授权且广告跟踪未关闭。
@property (nonatomic, assign) BOOL allowsAdvertisingIdentifier;

/// 是否在广告请求中输出明文 idfa（默认 NO，仅输出 idfa_md5）。
@property (nonatomic, assign) BOOL emitsRawAdvertisingIdentifier;

/// 是否输出拼多多旧版 caid / caid_info 字段（默认 NO，仅用于仍消费 CAID 的广告平台）。
@property (nonatomic, assign) BOOL emitsLegacyCAIDFields;

/// 内存中的身份缓存时长，默认 300 秒；0 表示每次都重新采集。
@property (nonatomic, assign) NSTimeInterval identityCacheDuration;

/// 是否打印调试日志，默认 NO。日志可能包含设备 ID/共享 ID，仅调试环境开启。
@property (nonatomic, assign) BOOL loggingEnabled;

/// 远端自建 ID 服务配置，默认未启用。
@property (nonatomic, strong) PBCrossRemoteConfiguration *remoteConfiguration;

/// 是否在加载身份时自动在后台刷新过期的远端 ID，默认 YES（仅在远端已启用时生效）。
@property (nonatomic, assign) BOOL automaticallyRefreshesRemoteIdentity;

/// 校验配置。
- (BOOL)validateWithError:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
