//
//  PBCrossRemoteResolver.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBCrossConfiguration;
@class PBCrossDeviceAttributes;
@class PBCrossIdentityStore;
@class PBCrossIdentifier;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PBCrossRemoteResolutionCompletion)(NSArray<PBCrossIdentifier *> * _Nullable identifiers,
                                                  NSDate * _Nullable resolvedAt,
                                                  NSError * _Nullable error);

/// 与 CAID API v1.15 兼容的自建 ID 服务客户端。completion 始终在主线程回调。
@interface PBCrossRemoteResolver : NSObject

- (instancetype)initWithConfiguration:(PBCrossConfiguration *)configuration
                                store:(PBCrossIdentityStore *)store;

@property (nonatomic, copy, readonly) PBCrossConfiguration *configuration;

/// 读取本地缓存的远端 ID（可能已过期）。
- (nullable NSArray<PBCrossIdentifier *> *)cachedIdentifiersWithResolvedAt:(NSDate * _Nullable * _Nullable)resolvedAt;

/// 缓存是否仍在 TTL 内。
- (BOOL)hasFreshCache;

/// 解析远端 ID；优先使用 TTL 内缓存，否则发起网络请求（受每日次数限制）。
- (void)resolveIdentifiersWithAttributes:(PBCrossDeviceAttributes *)attributes
                              completion:(nullable PBCrossRemoteResolutionCompletion)completion;

@end

NS_ASSUME_NONNULL_END
