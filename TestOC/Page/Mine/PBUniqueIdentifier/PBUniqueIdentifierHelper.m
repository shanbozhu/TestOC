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
static NSString * const kPBKeychainErrorDomain = @"PBUniqueIdentifierKeychain";
static NSString * const kPBDeviceCheckErrorDomain = @"PBUniqueIdentifierDeviceCheck";

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
    
    item.identifierError = nil;
    item.identifierCopyable = YES;
    
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
            NSError *error = nil;
            NSString *uuid = [self keychainUUIDStringWithError:&error];
            item.identifierValue = uuid;
            item.identifierError = error.localizedDescription;
            item.identifierCopyable = (uuid.length > 0 && error == nil);
            finish();
            break;
        }
        case PBUniqueIdentifierSchemeTypeDeviceCheck: {
            [self fetchDeviceCheckStatusWithCompletion:^(NSString *value, NSError *error) {
                item.identifierValue = value;
                item.identifierError = error.localizedDescription;
                // DeviceCheck 返回的是短时 Token/状态，不是可复用的设备标识，禁止复制。
                item.identifierCopyable = NO;
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

/// 构建 Keychain 查询/写入的基础字典（不含 kSecReturnData、kSecValueData 等操作项）
+ (NSMutableDictionary *)keychainBaseQuery {
    return [@{
        // kSecClassGenericPassword：以「账号+密码」形式存储任意小数据（此处存 UUID 字符串）
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        // kSecAttrService：业务模块标识，类似数据库的表名
        (__bridge id)kSecAttrService: kPBKeychainService,
        // kSecAttrAccount：具体键名，类似数据库的主键
        (__bridge id)kSecAttrAccount: kPBKeychainAccount,
        // 设备标识不跟随 iCloud Keychain 同步到其他设备
        (__bridge id)kSecAttrSynchronizable: @NO,
    } mutableCopy];
}

+ (NSError *)keychainErrorWithStatus:(OSStatus)status {
    NSString *message = CFBridgingRelease(SecCopyErrorMessageString(status, NULL));
    return [NSError errorWithDomain:kPBKeychainErrorDomain
                               code:status
                           userInfo:@{NSLocalizedDescriptionKey: message ?: @"Keychain 操作失败"}];
}

+ (NSString *)keychainDataError {
    return @"Keychain 中的标识格式损坏；为保护原数据，未自动覆盖";
}

+ (NSString *)UUIDStringFromKeychainData:(NSData *)data error:(NSError **)error {
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSUUID *uuid = value.length > 0 ? [[NSUUID alloc] initWithUUIDString:value] : nil;
    if (!uuid || [uuid.UUIDString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        if (error) {
            *error = [NSError errorWithDomain:kPBKeychainErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: [self keychainDataError]}];
        }
        return nil;
    }
    // 保留 Keychain 中的原始大小写，避免已有标识的字符串表示发生变化。
    return value;
}

/// 从 Keychain 读取 UUID；只有 errSecItemNotFound 才表示“没有记录”。
/// 其他状态（锁屏、权限、Keychain 损坏）必须返回错误，不能生成新 ID。
+ (NSString *)keychainReadUUIDWithStatus:(OSStatus *)status error:(NSError **)error {
    NSMutableDictionary *query = [self keychainBaseQuery];
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    CFTypeRef result = NULL;
    OSStatus readStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status) {
        *status = readStatus;
    }

    id object = CFBridgingRelease(result);
    if (readStatus != errSecSuccess) {
        if (readStatus != errSecItemNotFound && error) {
            *error = [self keychainErrorWithStatus:readStatus];
        }
        return nil;
    }
    if (![object isKindOfClass:[NSData class]]) {
        if (error) {
            *error = [NSError errorWithDomain:kPBKeychainErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: [self keychainDataError]}];
        }
        return nil;
    }
    return [self UUIDStringFromKeychainData:(NSData *)object error:error];
}

/// 获取 Keychain 中持久化的 UUID；仅在“确实没有记录”时创建。
/// 写失败时保留旧记录，绝不先删除再写入。
+ (NSString *)keychainUUIDStringWithError:(NSError **)error {
    OSStatus readStatus = errSecSuccess;
    NSError *readError = nil;
    NSString *existing = [self keychainReadUUIDWithStatus:&readStatus error:&readError];
    if (existing.length > 0) {
        return existing;
    }
    if (readStatus != errSecItemNotFound) {
        if (error) {
            *error = readError ?: [self keychainErrorWithStatus:readStatus];
        }
        return nil;
    }

    NSString *candidate = NSUUID.UUID.UUIDString;
    NSMutableDictionary *item = [self keychainBaseQuery];
    item[(__bridge id)kSecValueData] = [candidate dataUsingEncoding:NSUTF8StringEncoding];
    item[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;

    OSStatus addStatus = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
    if (addStatus == errSecSuccess) {
        return candidate;
    }
    if (addStatus == errSecDuplicateItem) {
        // 并发创建时读取先写入的记录，不能返回未保存的 candidate。
        OSStatus winnerStatus = errSecSuccess;
        NSError *winnerError = nil;
        NSString *winner = [self keychainReadUUIDWithStatus:&winnerStatus error:&winnerError];
        if (winner.length > 0) {
            return winner;
        }
        if (error) {
            *error = winnerError ?: [self keychainErrorWithStatus:winnerStatus];
        }
        return nil;
    }
    if (error) {
        *error = [self keychainErrorWithStatus:addStatus];
    }
    return nil;
}

#pragma mark - DeviceCheck

+ (NSError *)deviceCheckErrorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:kPBDeviceCheckErrorDomain
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey: message ?: @"DeviceCheck 操作失败"}];
}

/// DeviceCheck 只返回一次性的 Token / 风控状态，不是设备唯一标识；
/// 因此这里只展示“是否生成成功”，不展示或复制 Token 原文。
+ (void)fetchDeviceCheckStatusWithCompletion:(void (^)(NSString *value, NSError *error))completion {
    if (@available(iOS 11.0, *)) {
        DCDevice *device = DCDevice.currentDevice;
        if (!device.isSupported) {
            completion(@"DeviceCheck 不可用（模拟器通常不支持，需真机）", nil);
            return;
        }
        
        [device generateTokenWithCompletionHandler:^(NSData * _Nullable token, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    completion(nil, error);
                    return;
                }
                if (token.length == 0) {
                    completion(nil, [self deviceCheckErrorWithMessage:@"DeviceCheck Token 为空"]);
                    return;
                }
                completion(@"已生成一次性 Token（仅服务端校验用，非设备 ID）", nil);
            });
        }];
        return;
    }
    completion(nil, [self deviceCheckErrorWithMessage:@"iOS 11 以下不支持 DeviceCheck"]);
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
