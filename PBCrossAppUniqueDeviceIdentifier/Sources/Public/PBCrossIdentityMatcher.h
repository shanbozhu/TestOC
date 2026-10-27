//
//  PBCrossIdentityMatcher.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBCrossDeviceAttributes.h"
#import "PBCrossIdentity.h"

NS_ASSUME_NONNULL_BEGIN

/// 命中原因。
typedef NS_ENUM(NSUInteger, PBCrossIdentityMatchReason) {
    PBCrossIdentityMatchReasonNone = 0,
    /// 共享自建 ID 命中。
    PBCrossIdentityMatchReasonSharedIdentifier,
    /// 任一版本指纹/远端 ID 命中。
    PBCrossIdentityMatchReasonVersionedIdentifier,
    /// IDFA MD5 命中。
    PBCrossIdentityMatchReasonAdvertisingIdentifier,
    /// 设备属性相似度达到阈值。
    PBCrossIdentityMatchReasonDeviceAttributes,
};

FOUNDATION_EXPORT NSString *PBCrossIdentityMatchReasonDescription(PBCrossIdentityMatchReason reason);

/// 一次跨身份匹配的结果。
@interface PBCrossIdentityMatchResult : NSObject

@property (nonatomic, assign, readonly) BOOL matched;

/// 0 ~ 1。ID 命中为 1；属性匹配为相似度。
@property (nonatomic, assign, readonly) double confidence;

/// 属性相似度（即使未达到阈值也会返回，便于调参）。
@property (nonatomic, assign, readonly) double attributeSimilarity;

@property (nonatomic, assign, readonly) PBCrossIdentityMatchReason reason;

@property (nonatomic, copy, readonly, nullable) NSString *matchedIdentifier;
@property (nonatomic, copy, readonly, nullable) NSString *matchedVersion;

/// 各属性比较结果："equal" / "different" / "not_comparable"。
@property (nonatomic, copy, readonly) NSDictionary<PBCrossAttributeKey, NSString *> *attributeMatches;

- (NSDictionary<NSString *, id> *)dictionaryRepresentation;

@end

/**
 *  跨公司归因匹配器。
 *
 *  匹配优先级：共享 ID > 任一版本 ID > IDFA MD5 > 设备属性相似度。
 *  媒体侧把 ad request ext 中的 pb_cross_app 原样回传/上报，广告主侧用
 *  PBCrossIdentity + 本匹配器即可判断是否同一设备。
 */
@interface PBCrossIdentityMatcher : NSObject

/// 属性相似度阈值，默认 0.9。
@property (nonatomic, assign) double attributeMatchThreshold;

/// 参与比较的属性权重之和下限，默认 6，避免仅凭 1 个弱字段误判。
@property (nonatomic, assign) double minimumComparableAttributeWeight;

/// 是否使用 IDFA MD5 匹配，默认 YES。
@property (nonatomic, assign) BOOL matchesAdvertisingIdentifier;

/// 自定义属性权重（覆盖默认值）；设为 0 可禁用某字段。默认权重见文档。
@property (nonatomic, copy, nullable) NSDictionary<PBCrossAttributeKey, NSNumber *> *attributeWeights;

- (PBCrossIdentityMatchResult *)matchIdentity:(PBCrossIdentity *)identity
                                withIdentity:(PBCrossIdentity *)otherIdentity;

@end

NS_ASSUME_NONNULL_END
