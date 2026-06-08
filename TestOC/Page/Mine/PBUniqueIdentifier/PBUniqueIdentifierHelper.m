//
//  PBUniqueIdentifierHelper.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/8.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBUniqueIdentifierHelper.h"

#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <DeviceCheck/DeviceCheck.h>
#import <Security/Security.h>
#import <ifaddrs.h>
#import <net/if_dl.h>
#import <net/if_types.h>
#import <sys/socket.h>

// Keychain 存储的业务标识：Service 相当于「命名空间」，Account 相当于「键名」
// 两者组合唯一确定一条 Keychain 记录，同一 App 内请勿与其他业务复用
static NSString * const kPBKeychainService = @"com.damaiios.PBUniqueIdentifier";
static NSString * const kPBKeychainAccount = @"device_uuid";

@implementation PBUniqueIdentifierHelper

#pragma mark - Public

+ (NSArray<PBUniqueIdentifierItem *> *)allSchemeItems {
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger type = PBUniqueIdentifierSchemeTypeUDID; type <= PBUniqueIdentifierSchemeTypeMACAddress; type++) {
        [items addObject:[PBUniqueIdentifierItem itemWithSchemeType:(PBUniqueIdentifierSchemeType)type]];
    }
    return items.copy;
}

+ (void)refreshAllIdentifiersForItems:(NSArray<PBUniqueIdentifierItem *> *)items
                           completion:(void (^)(void))completion {
    dispatch_group_t group = dispatch_group_create();
    
    for (PBUniqueIdentifierItem *item in items) {
        dispatch_group_enter(group);
        [self refreshIdentifierForItem:item completion:^{
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
    });
}

+ (void)refreshIdentifierForItem:(PBUniqueIdentifierItem *)item
                      completion:(void (^)(void))completion {
    void (^finish)(void) = ^{
        if (completion) {
            completion();
        }
    };
    
    switch (item.schemeType) {
        case PBUniqueIdentifierSchemeTypeUDID: {
            item.identifierValue = [self udidDescription];
            finish();
            break;
        }
        case PBUniqueIdentifierSchemeTypeIDFA: {
            [self fetchIDFAWithCompletion:^(NSString *value) {
                item.identifierValue = value;
                finish();
            }];
            break;
        }
        case PBUniqueIdentifierSchemeTypeIDFV: {
            item.identifierValue = [self idfvString];
            finish();
            break;
        }
        case PBUniqueIdentifierSchemeTypeKeychainUUID: {
            item.identifierValue = [self keychainUUIDString];
            finish();
            break;
        }
        case PBUniqueIdentifierSchemeTypeDeviceCheck: {
            [self fetchDeviceCheckTokenWithCompletion:^(NSString *value) {
                item.identifierValue = value;
                finish();
            }];
            break;
        }
        case PBUniqueIdentifierSchemeTypeMACAddress: {
            item.identifierValue = [self macAddressDescription];
            finish();
            break;
        }
    }
}

+ (void)requestIDFAAuthorizationWithCompletion:(void (^)(void))completion {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(__unused ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion();
                }
            });
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

#pragma mark - UDID

+ (NSString *)udidDescription {
    return @"iOS 5 起已废弃，无公开 API 可获取真实 UDID";
}

#pragma mark - IDFA

+ (void)fetchIDFAWithCompletion:(void (^)(NSString *value))completion {
    if (@available(iOS 14, *)) {
        ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
        if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
            completion(@"需先请求 ATT 授权（点击「请求 IDFA 授权」）");
            return;
        }
        if (status == ATTrackingManagerAuthorizationStatusDenied) {
            completion(@"用户拒绝授权（可在 设置 > 隐私与安全性 > 跟踪 中修改）");
            return;
        }
        if (status == ATTrackingManagerAuthorizationStatusRestricted) {
            completion(@"设备受限，无法获取 IDFA");
            return;
        }
    }
    
    NSUUID *idfa = [ASIdentifierManager sharedManager].advertisingIdentifier;
    NSString *idfaString = idfa.UUIDString ?: @"";
    if ([idfaString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        completion(@"00000000-0000-0000-0000-000000000000（未授权或已开启「限制广告跟踪」）");
        return;
    }
    completion(idfaString);
}

#pragma mark - IDFV

+ (NSString *)idfvString {
    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    return idfv.UUIDString ?: @"无法获取 IDFV";
}

#pragma mark - Keychain + UUID

/**
 Keychain + UUID 方案核心思路：
 1. 首次启动：生成随机 UUID，写入 Keychain
 2. 后续启动：从 Keychain 读取已有 UUID，保证同一 App 标识稳定
 3. 卸载重装：Keychain 数据通常保留（同 Bundle ID + 同 Team ID），因此标识不变
 
 这是业务侧最常用的「设备/用户唯一标识」方案，无需用户授权。
 */

/// 获取 Keychain 中持久化的 UUID（不存在则创建并保存）
+ (NSString *)keychainUUIDString {
    // 优先读取，避免重复生成导致标识变化
    NSString *existing = [self keychainReadUUID];
    if (existing.length > 0) {
        return existing;
    }
    
    // 首次使用：生成标准 UUID（如 550E8400-E29B-41D4-A716-446655440000）
    NSString *uuid = [[NSUUID UUID] UUIDString];
    if ([self keychainSaveUUID:uuid]) {
        return uuid;
    }
    return @"Keychain 写入失败";
}

/// 构建 Keychain 查询/写入的基础字典（不含 kSecReturnData、kSecValueData 等操作项）
+ (NSMutableDictionary *)keychainBaseQuery {
    return [@{
        // kSecClassGenericPassword：以「账号+密码」形式存储任意小数据（此处存 UUID 字符串）
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        // kSecAttrService：业务模块标识，类似数据库的表名
        (__bridge id)kSecAttrService: kPBKeychainService,
        // kSecAttrAccount：具体键名，类似数据库的主键
        (__bridge id)kSecAttrAccount: kPBKeychainAccount,
    } mutableCopy];
}

/// 从 Keychain 读取已保存的 UUID，不存在时返回 nil
+ (NSString *)keychainReadUUID {
    NSMutableDictionary *query = [self keychainBaseQuery];
    // 要求 API 返回存储的二进制数据（而非仅返回状态码）
    query[(__bridge id)kSecReturnData] = @YES;
    // 只匹配一条记录（Service + Account 已唯一）
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    CFTypeRef result = NULL;
    // SecItemCopyMatching：按 query 条件查询 Keychain
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess && result) {
        NSData *data = (__bridge_transfer NSData *)result;
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

/// 将 UUID 写入 Keychain；写入前先删除旧值，避免重复添加报错
+ (BOOL)keychainSaveUUID:(NSString *)uuid {
    NSData *data = [uuid dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *query = [self keychainBaseQuery];
    
    // 若已有同 Service+Account 的记录，先删再写（SecItemAdd 不允许重复添加）
    SecItemDelete((__bridge CFDictionaryRef)query);
    
    query[(__bridge id)kSecValueData] = data;
    // kSecAttrAccessibleAfterFirstUnlock：设备首次解锁后可读
    // 兼顾安全性与后台可用性，也是卸载重装后数据保留的常用配置
    query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    return SecItemAdd((__bridge CFDictionaryRef)query, NULL) == errSecSuccess;
}

#pragma mark - DeviceCheck

+ (void)fetchDeviceCheckTokenWithCompletion:(void (^)(NSString *value))completion {
    if (@available(iOS 11.0, *)) {
        DCDevice *device = DCDevice.currentDevice;
        if (!device.isSupported) {
            completion(@"当前设备不支持 DeviceCheck");
            return;
        }
        
        [device generateTokenWithCompletionHandler:^(NSData * _Nullable token, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    completion([NSString stringWithFormat:@"Token 获取失败：%@", error.localizedDescription]);
                    return;
                }
                if (token.length == 0) {
                    completion(@"Token 为空");
                    return;
                }
                NSString *tokenBase64 = [token base64EncodedStringWithOptions:0];
                completion([NSString stringWithFormat:@"Token（Base64，每次请求不同，需服务端校验）：\n%@", tokenBase64]);
            });
        }];
        return;
    }
    completion(@"iOS 11 以下不支持 DeviceCheck");
}

#pragma mark - MAC Address

+ (NSString *)macAddressDescription {
    NSString *mac = [self macAddressFromInterface:@"en0"];
    if (mac.length == 0) {
        mac = [self macAddressFromInterface:@"pdp_ip0"];
    }
    
    if (mac.length == 0) {
        return @"无法获取（iOS 7+ 已屏蔽 Wi-Fi / 蜂窝 MAC 读取）";
    }
    if ([mac isEqualToString:@"02:00:00:00:00:00"]) {
        return @"02:00:00:00:00:00（系统占位值，非真实 MAC）";
    }
    return [NSString stringWithFormat:@"%@（若可读到也仅作参考，不可用于设备标识）", mac];
}

+ (NSString *)macAddressFromInterface:(NSString *)interfaceName {
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *cursor = NULL;
    NSString *macAddress = nil;
    
    if (getifaddrs(&interfaces) != 0) {
        return nil;
    }
    
    for (cursor = interfaces; cursor != NULL; cursor = cursor->ifa_next) {
        if (!cursor->ifa_addr) {
            continue;
        }
        if (cursor->ifa_addr->sa_family != AF_LINK) {
            continue;
        }
        if (![interfaceName isEqualToString:[NSString stringWithUTF8String:cursor->ifa_name]]) {
            continue;
        }
        
        struct sockaddr_dl *sdl = (struct sockaddr_dl *)cursor->ifa_addr;
        unsigned char *base = (unsigned char *)LLADDR(sdl);
        macAddress = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                      base[0], base[1], base[2], base[3], base[4], base[5]];
        break;
    }
    
    freeifaddrs(interfaces);
    return macAddress;
}

@end
