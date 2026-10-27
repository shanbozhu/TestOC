//
//  PBCrossAdRequestAdapter.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBCrossIdentity.h"

NS_ASSUME_NONNULL_BEGIN

/// 拼多多规范 6.2 联网类型。
typedef NS_ENUM(NSInteger, PBCrossConnectionType) {
    PBCrossConnectionTypeUnknown = 0,
    PBCrossConnectionTypeEthernet = 1,
    PBCrossConnectionTypeWiFi = 2,
    PBCrossConnectionTypeMobileUnknown = 3,
    PBCrossConnectionTypeMobile2G = 4,
    PBCrossConnectionTypeMobile3G = 5,
    PBCrossConnectionTypeMobile4G = 6,
    PBCrossConnectionTypeMobile5G = 7,
};

/// 拼多多规范 6.4 设备类型。
typedef NS_ENUM(NSInteger, PBCrossDeviceType) {
    PBCrossDeviceTypeUnknown = 0,
    PBCrossDeviceTypePhone = 1,
    PBCrossDeviceTypeComputer = 2,
    PBCrossDeviceTypeTV = 3,
};

/**
 *  广告请求上下文。SDK 不主动采集 IP/UA/网络类型/地理位置，由宿主填入。
 */
@interface PBCrossAdRequestContext : NSObject <NSCopying>

@property (nonatomic, copy, nullable) NSString *userAgent;
@property (nonatomic, copy, nullable) NSString *ipAddress;
@property (nonatomic, copy, nullable) NSString *ipv6Address;
@property (nonatomic, assign) PBCrossDeviceType deviceType;
@property (nonatomic, assign) PBCrossConnectionType connectionType;

/// 覆盖 Device.model（营销机型名），为空时使用 hw.machine。
@property (nonatomic, copy, nullable) NSString *modelName;

/// 覆盖 PDD carrier 枚举（mobile/unicom/telecom/unknown），为空时由 MCC/MNC 推导。
@property (nonatomic, copy, nullable) NSString *carrier;

/// 明文 IDFA。默认不填；仅在用户授权且业务确有必要时由宿主传入。
@property (nonatomic, copy, nullable) NSString *advertisingIdentifier;

/// 拼多多 paid / paid_1_4 标识，由宿主从对应 SDK 获取。
@property (nonatomic, copy, nullable) NSString *paid;
@property (nonatomic, copy, nullable) NSString *paid14;

/// Android 字段，预留给跨平台宿主。
@property (nonatomic, copy, nullable) NSString *gaid;
@property (nonatomic, copy, nullable) NSString *gaidMD5;

/// 屏幕像素宽高；0 表示使用采集到的屏幕分辨率。
@property (nonatomic, assign) NSInteger screenWidth;
@property (nonatomic, assign) NSInteger screenHeight;

/// 合并进 Device.ext 的宿主自定义字段。
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *additionalExtension;

@end

/**
 *  把 PBCrossIdentity 转换为拼多多 Bid Request Device 对象与跨公司追踪参数。
 *
 *  输出：
 *  - Device 对象中的 CAID 兼容字段：birth_time、boot_time、update_time、last_update_time、idfa_md5；
 *  - Device.ext.pb_cross_app：完整身份快照，供其他媒体/广告主还原匹配；
 *  - 可选旧版 caid / caid_info（默认关闭）；
 *  - trackingParameters：用于点击/曝光监测 URL 的扁平参数。
 */
@interface PBCrossAdRequestAdapter : NSObject

+ (instancetype)adapterWithIdentity:(PBCrossIdentity *)identity
                            context:(nullable PBCrossAdRequestContext *)context;

- (instancetype)initWithIdentity:(PBCrossIdentity *)identity
                         context:(nullable PBCrossAdRequestContext *)context NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, strong, readonly) PBCrossIdentity *identity;
@property (nonatomic, strong, readonly) PBCrossAdRequestContext *context;

/// 是否输出明文 idfa，默认 NO。需要同时满足采集时已授权。
@property (nonatomic, assign) BOOL emitsRawAdvertisingIdentifier;

/// 是否输出旧版 caid / caid_info 字段，默认 NO。
@property (nonatomic, assign) BOOL emitsLegacyCAIDFields;

/// 拼多多 Device 对象（含 ext 字符串）。
- (NSDictionary<NSString *, id> *)deviceDictionary;

/// Device.ext 的 JSON 对象。
- (NSDictionary<NSString *, id> *)extensionObject;

/// Device.ext 的 JSON 字符串。
- (nullable NSString *)deviceExtensionJSONString;

/// 跨公司追踪 URL 参数（未做 URL 编码，调用方需自行编码）。
- (NSDictionary<NSString *, NSString *> *)trackingParameters;

@end

NS_ASSUME_NONNULL_END
