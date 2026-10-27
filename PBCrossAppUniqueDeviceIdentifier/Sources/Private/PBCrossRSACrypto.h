//
//  PBCrossRSACrypto.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

/// CAID 兼容的 RSA 工具：公钥加密（PKCS#1 v1.5）与公钥"解密"（Raw + 手动去除 Type 1 padding）。
@interface PBCrossRSACrypto : NSObject

/// 解析 Base64/PEM 公钥。支持 X.509 证书、PKCS#1 RSAPublicKey、SPKI SubjectPublicKeyInfo。
/// 返回值需调用方 CFRelease。
+ (nullable SecKeyRef)PBCopyPublicKeyFromString:(NSString *)publicKeyString
                                          error:(NSError * _Nullable * _Nullable)error CF_RETURNS_RETAINED;

/// 分段 RSA 公钥加密（PKCS#1 v1.5），返回密文。
+ (nullable NSData *)encryptData:(NSData *)data
                       publicKey:(SecKeyRef)publicKey
                           error:(NSError * _Nullable * _Nullable)error;

/// 分段 Raw RSA 公钥"解密"并去除 00 01 FF...00 padding。
+ (nullable NSData *)decryptData:(NSData *)data
                       publicKey:(SecKeyRef)publicKey
                           error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
