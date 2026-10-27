//
//  PBCrossCrypto.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 指纹计算所需的摘要工具（CommonCrypto）。
@interface PBCrossCrypto : NSObject

/// 32 位小写 MD5，用于 CAID 兼容字段 deviceName。
+ (NSString *)MD5HexString:(NSString *)string;

/// 64 位小写 SHA-256。
+ (NSString *)SHA256HexString:(NSString *)string;

/// HMAC-SHA256，输出 64 位小写十六进制。
+ (NSString *)HMACSHA256HexString:(NSString *)string key:(NSString *)key;

/// 小写 UUID 字符串。
+ (NSString *)randomUUIDString;

@end

NS_ASSUME_NONNULL_END
