//
//  PBCrossIdentityGenerator.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBCrossConfiguration;
@class PBCrossDeviceAttributes;
@class PBCrossIdentifier;
@class PBCrossIdentifierVersion;

NS_ASSUME_NONNULL_BEGIN

/// pb-xid-v1 指纹生成器。算法规范见 Docs/CrossCompanyIdentifierSpec.md。
@interface PBCrossIdentityGenerator : NSObject

/// 按 configuration.supportedVersions 顺序生成指纹 ID（当前版本在前）。
+ (NSArray<PBCrossIdentifier *> *)fingerprintIdentifiersWithAttributes:(PBCrossDeviceAttributes *)attributes
                                                        configuration:(PBCrossConfiguration *)configuration;

/// 规范化字符串：pb-xid-v1|{version}|{key}={value}|...（key 按 ASCII 升序）。
+ (NSString *)canonicalStringForVersion:(PBCrossIdentifierVersion *)version
                             attributes:(PBCrossDeviceAttributes *)attributes;

/// 对规范化字符串做 HMAC-SHA256，截取前 32 位十六进制。
+ (NSString *)identifierStringForCanonicalString:(NSString *)canonicalString salt:(NSString *)salt;

@end

NS_ASSUME_NONNULL_END
