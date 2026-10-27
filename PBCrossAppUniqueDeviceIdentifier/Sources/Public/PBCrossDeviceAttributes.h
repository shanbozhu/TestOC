//
//  PBCrossDeviceAttributes.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  设备属性的统一 Field Name。
 *
 *  其中前 14 个 Key 与 CAID API 文档（api_v1.15）5.1 节"设备终端公共信息采集字段"完全一致，
 *  可以直接序列化为 CAID 兼容的设备信息字典；其余 Key 为本 SDK 的扩展字段。
 *  所有 Key 同时也是跨公司指纹算法（pb-xid-v1）的规范化输入名，合作方必须使用同一套 Key。
 */
typedef NSString *PBCrossAttributeKey NS_TYPED_EXTENSIBLE_ENUM;

/// 设备启动时间（秒，Unix 时间戳）。CAID: bootTimeInSec。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyBootTimeInSec;
/// 国家/地区代码，如 CN。CAID: countryCode。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyCountryCode;
/// 语言，如 zh-Hans-CN。CAID: language。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyLanguage;
/// 设备名称的 MD5（32 位小写）。CAID: deviceName。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyDeviceName;
/// 系统版本，如 18.0。CAID: systemVersion。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeySystemVersion;
/// 硬件标识，如 iPhone13,2。CAID: machine。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyMachine;
/// 运营商名称，如 中国移动。CAID: carrierInfo。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyCarrierInfo;
/// 物理内存字节数。CAID: memory。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyMemory;
/// 磁盘总容量字节数。CAID: disk。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyDisk;
/// 系统更新时间（秒，保留 6 位小数）。CAID: sysFileTime。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeySysFileTime;
/// 硬件 Model，如 D22AP。CAID: model。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyModel;
/// 时区相对 GMT 的偏移秒数。CAID: timeZone。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyTimeZone;
/// 系统挂载标识。CAID: mntId。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyMntID;
/// 设备初始化时间（秒，保留 9 位小数）。CAID: deviceInitTime。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyDeviceInitTime;
/// 【扩展】identifierForVendor（小写）。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyIDFV;
/// 【扩展】IDFA 的 MD5（仅用户授权后可采集）。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyIDFAMD5;
/// 【扩展】屏幕分辨率，格式：像素宽 x 像素高 @scale，如 1170x2532@3。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyScreenResolution;
/// 【扩展】CPU 核心数。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyProcessorCount;
/// 【扩展】时区标识，如 Asia/Shanghai。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyTimeZoneIdentifier;
/// 【扩展】系统名称，如 iOS。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeySystemName;
/// 【扩展】运营商 MCC，如 460。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyCarrierMCC;
/// 【扩展】运营商 MNC，如 00。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeyCarrierMNC;
/// 【扩展】是否模拟器，@"1"/@"0"。
FOUNDATION_EXPORT PBCrossAttributeKey const PBCrossAttributeKeySimulator;

/**
 *  一次采集得到的设备属性快照（不可变）。
 *
 *  设计说明：
 *  - 以 Key-Value 字典作为唯一存储，便于增加字段与跨公司约定字段集；
 *  - 只在内存中保存原始 IDFA，dictionaryRepresentation 中仅输出 idfa_md5；
 *  - 空值不写入 values，读取时返回 nil，生成指纹时统一按空字符串处理。
 */
@interface PBCrossDeviceAttributes : NSObject <NSCopying>

/// 便捷构造。values 中非 NSString 的值会被忽略，空字符串会被丢弃。
+ (instancetype)attributesWithValues:(NSDictionary<PBCrossAttributeKey, NSString *> *)values;

/// 便捷构造，可携带原始 IDFA（不会进入 dictionaryRepresentation）。
+ (instancetype)attributesWithValues:(NSDictionary<PBCrossAttributeKey, NSString *> *)values
             advertisingIdentifier:(nullable NSString *)advertisingIdentifier;

/// 从 dictionaryRepresentation 还原（用于接收媒体/广告主回传的设备信息）。
+ (nullable instancetype)attributesWithDictionaryRepresentation:(NSDictionary<NSString *, id> *)dictionary;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 所有已采集的非空属性。
@property (nonatomic, copy, readonly) NSDictionary<PBCrossAttributeKey, NSString *> *values;

/// 原始 IDFA（仅当宿主配置允许且用户已授权时存在，不会序列化）。
@property (nonatomic, copy, readonly, nullable) NSString *advertisingIdentifier;

/// 读取任意属性，未知或空值返回 nil。
- (nullable NSString *)valueForKey:(PBCrossAttributeKey)key;

#pragma mark - CAID 兼容字段

@property (nonatomic, copy, readonly, nullable) NSString *bootTimeInSec;
@property (nonatomic, copy, readonly, nullable) NSString *countryCode;
@property (nonatomic, copy, readonly, nullable) NSString *language;
@property (nonatomic, copy, readonly, nullable) NSString *deviceNameMD5;
@property (nonatomic, copy, readonly, nullable) NSString *systemVersion;
@property (nonatomic, copy, readonly, nullable) NSString *machine;
@property (nonatomic, copy, readonly, nullable) NSString *carrierInfo;
@property (nonatomic, copy, readonly, nullable) NSString *memory;
@property (nonatomic, copy, readonly, nullable) NSString *disk;
@property (nonatomic, copy, readonly, nullable) NSString *sysFileTime;
@property (nonatomic, copy, readonly, nullable) NSString *hardwareModel;
@property (nonatomic, copy, readonly, nullable) NSString *timeZone;
@property (nonatomic, copy, readonly, nullable) NSString *mntID;
@property (nonatomic, copy, readonly, nullable) NSString *deviceInitTime;

#pragma mark - 扩展字段

@property (nonatomic, copy, readonly, nullable) NSString *identifierForVendor;
@property (nonatomic, copy, readonly, nullable) NSString *advertisingIdentifierMD5;
@property (nonatomic, copy, readonly, nullable) NSString *screenResolution;
@property (nonatomic, assign, readonly) NSInteger processorCount;
@property (nonatomic, copy, readonly, nullable) NSString *timeZoneIdentifier;
@property (nonatomic, copy, readonly, nullable) NSString *systemName;
@property (nonatomic, copy, readonly, nullable) NSString *carrierMobileCountryCode;
@property (nonatomic, copy, readonly, nullable) NSString *carrierMobileNetworkCode;
@property (nonatomic, assign, readonly, getter=isSimulator) BOOL simulator;

#pragma mark - 序列化

/// CAID API 5.1 节规定的 14 个字段（不与扩展字段混用）。
+ (NSArray<PBCrossAttributeKey> *)CAIDCompatibleAttributeKeys;

/// CAID 设备信息字典；includingEmptyValues 为 YES 时缺失字段以 @"" 补齐。
- (NSDictionary<NSString *, NSString *> *)CAIDDeviceInfoDictionaryIncludingEmptyValues:(BOOL)includingEmptyValues;

/// 可 JSON 序列化的属性字典（不含原始 IDFA）。
- (NSDictionary<NSString *, id> *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
