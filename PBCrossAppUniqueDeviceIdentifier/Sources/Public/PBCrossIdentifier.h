//
//  PBCrossIdentifier.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 标识来源。
typedef NS_ENUM(NSUInteger, PBCrossIdentifierKind) {
    /// 由设备属性 + 盐值在本地确定生成，跨 App/跨公司一致。
    PBCrossIdentifierKindFingerprint = 0,
    /// 由远端自建 ID 服务返回。
    PBCrossIdentifierKindRemote = 1,
    /// 由接入方服务端下发（例如广告主侧的归因 ID）。
    PBCrossIdentifierKindServer = 2,
};

FOUNDATION_EXPORT NSString *PBCrossIdentifierKindToString(PBCrossIdentifierKind kind);
FOUNDATION_EXPORT PBCrossIdentifierKind PBCrossIdentifierKindFromString(NSString *string);

/**
 *  一个带版本号的设备 ID。
 *
 *  同一台设备可以同时存在多个版本的 ID（当前版本 + 上一版本），归因方任一命中即可关联。
 */
@interface PBCrossIdentifier : NSObject <NSCopying>

+ (nullable instancetype)identifierWithValue:(NSString *)value
                                     version:(NSString *)version
                                        kind:(PBCrossIdentifierKind)kind;

- (nullable instancetype)initWithValue:(NSString *)value
                               version:(NSString *)version
                                  kind:(PBCrossIdentifierKind)kind NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// ID 值，通常为 32 位小写十六进制字符串。
@property (nonatomic, copy, readonly) NSString *value;

/// 算法版本号（如 20261001）或服务端版本号。
@property (nonatomic, copy, readonly) NSString *version;

@property (nonatomic, assign, readonly) PBCrossIdentifierKind kind;

- (BOOL)isEqualToIdentifier:(PBCrossIdentifier *)identifier;

/// { "id": "...", "version": "...", "kind": "fingerprint" }
- (NSDictionary<NSString *, id> *)dictionaryRepresentation;

+ (nullable instancetype)identifierWithDictionaryRepresentation:(NSDictionary<NSString *, id> *)dictionary;

@end

NS_ASSUME_NONNULL_END
