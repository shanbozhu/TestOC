//
//  PBCrossIdentity.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBCrossDeviceAttributes.h"
#import "PBCrossIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

/// 身份数据的来源组合。
typedef NS_OPTIONS(NSUInteger, PBCrossIdentitySource) {
    PBCrossIdentitySourceNone = 0,
    /// 本地由设备属性确定生成（跨公司可复现）。
    PBCrossIdentitySourceFingerprint = 1 << 0,
    /// 通过 Keychain Access Group / App Group 共享的自建 ID。
    PBCrossIdentitySourceSharedStorage = 1 << 1,
    /// 自建 ID 服务下发。
    PBCrossIdentitySourceRemote = 1 << 2,
    /// 接入方服务端下发（setServerIssuedSharedID）。
    PBCrossIdentitySourceServer = 1 << 3,
};

FOUNDATION_EXPORT NSString *PBCrossIdentitySourceDescription(PBCrossIdentitySource source);

/**
 *  一次完整的设备身份快照。
 *
 *  同时包含：
 *  - 本地按版本生成的指纹 ID（默认当前版本 + 上一版本）；
 *  - 跨 App 共享的自建 UUID（可选，取决于 Keychain/App Group 配置）；
 *  - 远端服务返回的版本化 ID（可选）；
 *  - 采集到的设备属性，供广告归因方做属性相似度匹配。
 */
@interface PBCrossIdentity : NSObject <NSCopying>

- (instancetype)initWithSharedID:(NSString *)sharedID
                     identifiers:(NSArray<PBCrossIdentifier *> *)identifiers
                      attributes:(PBCrossDeviceAttributes *)attributes
       previousSystemUpdateTime:(NSString *)previousSystemUpdateTime
                       algorithm:(NSString *)algorithm
                         sources:(PBCrossIdentitySource)sources
                     generatedAt:(NSDate *)generatedAt
                remoteResolvedAt:(nullable NSDate *)remoteResolvedAt NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 跨 App 共享的自建 ID；未获授权共享时仍然会生成一个本 App 内稳定的 UUID。
@property (nonatomic, copy, readonly) NSString *sharedID;

/// 全部版本化 ID，顺序：本地指纹（当前、上一版本）、远端。共享/服务端 ID 见 sharedID。
@property (nonatomic, copy, readonly) NSArray<PBCrossIdentifier *> *identifiers;

/// 设备属性快照。
@property (nonatomic, strong, readonly) PBCrossDeviceAttributes *attributes;

/// 上一次系统更新时间（PDD last_update_time），用于系统升级前后关联。
@property (nonatomic, copy, readonly) NSString *previousSystemUpdateTime;

/// 算法标识，如 pb-xid-v1。
@property (nonatomic, copy, readonly) NSString *algorithm;

@property (nonatomic, assign, readonly) PBCrossIdentitySource sources;

@property (nonatomic, strong, readonly) NSDate *generatedAt;

/// 远端 ID 的解析时间；无远端数据时为 nil。
@property (nonatomic, strong, readonly, nullable) NSDate *remoteResolvedAt;

/// 当前版本指纹 ID。
@property (nonatomic, copy, readonly, nullable) NSString *currentIdentifier;
@property (nonatomic, copy, readonly, nullable) NSString *currentVersion;

/// 上一版本指纹 ID（用于归因时兼容旧版本）。
@property (nonatomic, copy, readonly, nullable) NSString *previousIdentifier;
@property (nonatomic, copy, readonly, nullable) NSString *previousVersion;

/// 去重后的全部 ID（按 ID 值去重，值不区分大小写）。
@property (nonatomic, copy, readonly) NSArray<PBCrossIdentifier *> *allIdentifiers;

- (NSArray<PBCrossIdentifier *> *)identifiersWithKind:(PBCrossIdentifierKind)kind;

- (nullable PBCrossIdentifier *)identifierForVersion:(NSString *)version;

/// 可直接写入 ad request ext 的 JSON 字典。
- (NSDictionary<NSString *, id> *)dictionaryRepresentation;

/// 从媒体/广告主回传的 JSON 还原，用于跨公司归因匹配。
+ (nullable instancetype)identityWithDictionaryRepresentation:(NSDictionary<NSString *, id> *)dictionary;

/// 从广告请求 Device.ext（含 pb_cross_app）或 pb_cross_app 本身还原。
+ (nullable instancetype)identityWithAdRequestExtension:(NSDictionary<NSString *, id> *)extension;

/// 从 Device.ext 的 JSON 字符串还原（即拼多多 Device.ext 字段）。
+ (nullable instancetype)identityWithAdRequestExtensionJSONString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
