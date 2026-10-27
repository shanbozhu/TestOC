//
//  PBCrossIdentityStore.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossIdentityStore.h"
#import "PBCrossConfiguration.h"
#import "PBCrossCrypto.h"
#import "PBCrossLogging.h"
#import <Security/Security.h>

static NSString * const PBCrossSharedIDKey = @"pb_shared_id";
static NSString * const PBCrossServerSharedIDKey = @"pb_server_shared_id";
static NSString * const PBCrossRemoteCacheKeyPrefix = @"pb_remote_cache";
static NSString * const PBCrossRemoteRequestLogKeyPrefix = @"pb_remote_request_log";
static NSString * const PBCrossSystemUpdateHistoryKey = @"pb_system_update_history";

static BOOL PBCrossIsValidSharedID(NSString *sharedID)
{
    if (sharedID.length == 0 || sharedID.length > 128) {
        return NO;
    }
    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:
                               @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~+/="];
    return [sharedID rangeOfCharacterFromSet:allowed.invertedSet].location == NSNotFound;
}

static NSString *PBCrossCurrentDayKey(void)
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                               fromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%04ld%02ld%02ld",
            (long)components.year, (long)components.month, (long)components.day];
}

@interface PBCrossIdentityStore ()

@property (nonatomic, copy, readwrite) PBCrossConfiguration *configuration;
@property (nonatomic, strong) NSUserDefaults *standardDefaults;
@property (nonatomic, strong, nullable) NSUserDefaults *groupDefaults;

@end

@implementation PBCrossIdentityStore

- (instancetype)initWithConfiguration:(PBCrossConfiguration *)configuration
{
    self = [super init];
    if (self) {
        _configuration = [configuration copy] ?: [[PBCrossConfiguration alloc] init];
        _standardDefaults = [NSUserDefaults standardUserDefaults];

        NSString *groupIdentifier = _configuration.appGroupIdentifier;
        if (groupIdentifier.length > 0) {
            NSURL *containerURL = [[NSFileManager defaultManager]
                                   containerURLForSecurityApplicationGroupIdentifier:groupIdentifier];
            if (containerURL) {
                _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:groupIdentifier];
            } else {
                PBCrossLog(_configuration, @"App Group 不可用，已回退到 App 私有存储: %@", groupIdentifier);
            }
        }
    }
    return self;
}

#pragma mark - NSUserDefaults

- (nullable NSString *)defaultsStringForKey:(NSString *)key
{
    NSString *value = [self.groupDefaults stringForKey:key];
    if (value.length == 0) {
        value = [self.standardDefaults stringForKey:key];
    }
    return value.length > 0 ? value : nil;
}

- (void)setDefaultsString:(NSString *)value forKey:(NSString *)key
{
    if (value.length == 0) {
        [self.groupDefaults removeObjectForKey:key];
        [self.standardDefaults removeObjectForKey:key];
    } else {
        [self.groupDefaults setObject:value forKey:key];
        [self.standardDefaults setObject:value forKey:key];
    }
}

- (void)removeDefaultsValueForKey:(NSString *)key
{
    [self.groupDefaults removeObjectForKey:key];
    [self.standardDefaults removeObjectForKey:key];
}

- (nullable id)defaultsJSONObjectForKey:(NSString *)key
{
    NSString *json = [self defaultsStringForKey:key];
    if (json.length == 0) {
        return nil;
    }
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return object;
}

- (void)setDefaultsJSONObject:(nullable id)object forKey:(NSString *)key
{
    if (!object) {
        [self removeDefaultsValueForKey:key];
        return;
    }
    if (![NSJSONSerialization isValidJSONObject:object]) {
        PBCrossLog(self.configuration, @"JSON 序列化失败，忽略本次写入: %@", key);
        return;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:NULL];
    NSString *json = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
    if (json.length == 0) {
        return;
    }
    [self setDefaultsString:json forKey:key];
}

#pragma mark - Keychain

- (NSMutableDictionary<id, id> *)keychainQueryForKey:(NSString *)key accessGroup:(nullable NSString *)accessGroup
{
    NSMutableDictionary<id, id> *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrService] = self.configuration.keychainService;
    query[(__bridge id)kSecAttrAccount] = key;
    if (accessGroup.length > 0) {
        query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
    }
    return query;
}

- (nullable NSString *)keychainStringForKey:(NSString *)key accessGroup:(nullable NSString *)accessGroup
{
    NSMutableDictionary<id, id> *query = [self keychainQueryForKey:key accessGroup:accessGroup];
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess || result == NULL) {
        if (status != errSecItemNotFound) {
            PBCrossLog(self.configuration, @"Keychain 读取失败 account=%@ group=%@ status=%ld",
                       key, accessGroup ?: @"-", (long)status);
        }
        if (result != NULL) {
            CFRelease(result);
        }
        return nil;
    }

    NSData *data = CFBridgingRelease(result);
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return value.length > 0 ? value : nil;
}

- (BOOL)writeKeychainString:(NSString *)value forKey:(NSString *)key accessGroup:(nullable NSString *)accessGroup
{
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return NO;
    }

    NSDictionary<id, id> *updateAttributes = @{(__bridge id)kSecValueData: data};
    NSMutableDictionary<id, id> *query = [self keychainQueryForKey:key accessGroup:accessGroup];
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateAttributes);
    if (status == errSecSuccess) {
        return YES;
    }

    if (status == errSecItemNotFound) {
        NSMutableDictionary<id, id> *addQuery = [query mutableCopy];
        addQuery[(__bridge id)kSecValueData] = data;
        addQuery[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
        addQuery[(__bridge id)kSecAttrSynchronizable] = @NO;
        status = SecItemAdd((__bridge CFDictionaryRef)addQuery, NULL);
        if (status == errSecSuccess) {
            return YES;
        }
        if (status == errSecDuplicateItem) {
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateAttributes);
            if (status == errSecSuccess) {
                return YES;
            }
        }
    }

    PBCrossLog(self.configuration, @"Keychain 写入失败 account=%@ group=%@ status=%ld",
               key, accessGroup ?: @"-", (long)status);
    return NO;
}

- (void)removeKeychainValueForKey:(NSString *)key accessGroup:(nullable NSString *)accessGroup
{
    NSMutableDictionary<id, id> *query = [self keychainQueryForKey:key accessGroup:accessGroup];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        PBCrossLog(self.configuration, @"Keychain 删除失败 account=%@ group=%@ status=%ld",
                   key, accessGroup ?: @"-", (long)status);
    }
}

- (nullable NSString *)keychainStringForKey:(NSString *)key
{
    NSString *accessGroup = self.configuration.keychainAccessGroup;
    NSString *value = [self keychainStringForKey:key accessGroup:accessGroup];
    if (value.length == 0 && accessGroup.length > 0) {
        // 未正确配置 Keychain 共享 entitlement 时，回退到 App 私有 Keychain，避免 ID 丢失。
        value = [self keychainStringForKey:key accessGroup:nil];
    }
    return value;
}

- (BOOL)writeKeychainString:(NSString *)value forKey:(NSString *)key
{
    NSString *accessGroup = self.configuration.keychainAccessGroup;
    BOOL success = [self writeKeychainString:value forKey:key accessGroup:accessGroup];
    if (!success && accessGroup.length > 0) {
        success = [self writeKeychainString:value forKey:key accessGroup:nil];
    }
    return success;
}

- (void)removeKeychainValueForKey:(NSString *)key
{
    NSString *accessGroup = self.configuration.keychainAccessGroup;
    [self removeKeychainValueForKey:key accessGroup:accessGroup];
    if (accessGroup.length > 0) {
        [self removeKeychainValueForKey:key accessGroup:nil];
    }
}

#pragma mark - Shared ID

- (void)mirrorSharedID:(NSString *)sharedID
{
    NSString *keychainValue = [self keychainStringForKey:PBCrossSharedIDKey];
    if (![keychainValue isEqualToString:sharedID]) {
        if (![self writeKeychainString:sharedID forKey:PBCrossSharedIDKey]) {
            PBCrossLog(self.configuration, @"共享 ID 写入 Keychain 失败，将依赖 UserDefaults");
        }
    }

    NSString *defaultsValue = [self defaultsStringForKey:PBCrossSharedIDKey];
    if (![defaultsValue isEqualToString:sharedID]) {
        [self setDefaultsString:sharedID forKey:PBCrossSharedIDKey];
    }
}

- (NSString *)sharedIDCreatingIfNeeded:(BOOL)create serverIssued:(nullable BOOL *)serverIssued
{
    @synchronized(self) {
        if (serverIssued != NULL) {
            *serverIssued = NO;
        }

        NSString *serverSharedID = [self keychainStringForKey:PBCrossServerSharedIDKey];
        if (serverSharedID.length == 0) {
            serverSharedID = [self defaultsStringForKey:PBCrossServerSharedIDKey];
        }
        if (serverSharedID.length > 0) {
            if (serverIssued != NULL) {
                *serverIssued = YES;
            }
            [self mirrorSharedID:serverSharedID];
            return serverSharedID;
        }

        NSString *sharedID = [self keychainStringForKey:PBCrossSharedIDKey];
        if (sharedID.length == 0) {
            sharedID = [self defaultsStringForKey:PBCrossSharedIDKey];
        }

        if (sharedID.length == 0 && create) {
            sharedID = [PBCrossCrypto randomUUIDString];
            PBCrossLog(self.configuration, @"首次生成共享设备 ID: %@", sharedID);
        }

        if (sharedID.length > 0) {
            [self mirrorSharedID:sharedID];
        }
        return sharedID ?: @"";
    }
}

- (BOOL)setServerIssuedSharedID:(nullable NSString *)sharedID
{
    if (sharedID.length == 0) {
        @synchronized(self) {
            [self removeKeychainValueForKey:PBCrossServerSharedIDKey];
            [self removeDefaultsValueForKey:PBCrossServerSharedIDKey];
        }
        return YES;
    }

    NSString *trimmed = [sharedID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!PBCrossIsValidSharedID(trimmed)) {
        PBCrossLog(self.configuration, @"服务端下发的共享 ID 非法，已忽略");
        return NO;
    }

    @synchronized(self) {
        [self setDefaultsString:trimmed forKey:PBCrossServerSharedIDKey];
        if (![self writeKeychainString:trimmed forKey:PBCrossServerSharedIDKey]) {
            PBCrossLog(self.configuration, @"服务端共享 ID 写入 Keychain 失败，将依赖 UserDefaults");
        }
        [self mirrorSharedID:trimmed];
    }
    return YES;
}

#pragma mark - Remote cache / rate limit

- (NSString *)remoteServiceScope
{
    PBCrossRemoteConfiguration *remoteConfiguration = self.configuration.remoteConfiguration;
    NSString *seed = [NSString stringWithFormat:@"%@|%@",
                      remoteConfiguration.developerID ?: @"",
                      remoteConfiguration.endpointURL.absoluteString ?: @""];
    return [PBCrossCrypto MD5HexString:seed];
}

- (NSString *)remoteCacheKey
{
    return [NSString stringWithFormat:@"%@.%@", PBCrossRemoteCacheKeyPrefix, [self remoteServiceScope]];
}

- (NSString *)remoteRequestLogKey
{
    return [NSString stringWithFormat:@"%@.%@", PBCrossRemoteRequestLogKeyPrefix, [self remoteServiceScope]];
}

- (nullable NSDictionary<NSString *, id> *)remoteCache
{
    @synchronized(self) {
        id object = [self defaultsJSONObjectForKey:[self remoteCacheKey]];
        return [object isKindOfClass:[NSDictionary class]] ? object : nil;
    }
}

- (void)setRemoteCache:(nullable NSDictionary<NSString *, id> *)cache
{
    @synchronized(self) {
        [self setDefaultsJSONObject:cache forKey:[self remoteCacheKey]];
    }
}

- (BOOL)registerRemoteRequestIfAllowed:(NSUInteger)dailyLimit
{
    if (dailyLimit == 0) {
        return NO;
    }

    @synchronized(self) {
        id object = [self defaultsJSONObjectForKey:[self remoteRequestLogKey]];
        NSDictionary *log = [object isKindOfClass:[NSDictionary class]] ? object : @{};
        NSString *today = PBCrossCurrentDayKey();
        NSUInteger count = [log[@"day"] isEqual:today] ? [log[@"count"] unsignedIntegerValue] : 0;
        if (count >= dailyLimit) {
            return NO;
        }

        [self setDefaultsJSONObject:@{@"day": today, @"count": @(count + 1)}
                             forKey:[self remoteRequestLogKey]];
        return YES;
    }
}

#pragma mark - System update history

- (NSString *)updateSystemUpdateTimeHistoryWithCurrentValue:(nullable NSString *)currentValue
{
    @synchronized(self) {
        id object = [self defaultsJSONObjectForKey:PBCrossSystemUpdateHistoryKey];
        NSDictionary *history = [object isKindOfClass:[NSDictionary class]] ? object : @{};
        NSString *storedCurrent = [history[@"current"] isKindOfClass:[NSString class]] ? history[@"current"] : nil;
        NSString *previous = [history[@"previous"] isKindOfClass:[NSString class]] ? history[@"previous"] : @"";

        if (currentValue.length == 0) {
            return previous ?: @"";
        }

        if (storedCurrent.length > 0 && ![storedCurrent isEqualToString:currentValue]) {
            previous = storedCurrent;
        }
        NSDictionary *updated = @{
            @"current": currentValue,
            @"previous": previous ?: @"",
        };
        [self setDefaultsJSONObject:updated forKey:PBCrossSystemUpdateHistoryKey];
        return previous ?: @"";
    }
}

#pragma mark - Reset

- (void)removeDefaultsKeysWithPrefix:(NSString *)prefix
{
    NSMutableSet<NSString *> *keys = [NSMutableSet set];
    NSDictionary *standardValues = self.standardDefaults.dictionaryRepresentation;
    if (standardValues) {
        [keys addObjectsFromArray:standardValues.allKeys];
    }
    NSDictionary *groupValues = self.groupDefaults.dictionaryRepresentation;
    if (groupValues) {
        [keys addObjectsFromArray:groupValues.allKeys];
    }
    for (NSString *key in keys) {
        if ([key isKindOfClass:[NSString class]] && [key hasPrefix:prefix]) {
            [self removeDefaultsValueForKey:key];
        }
    }
}

- (void)clearStoredIdentity
{
    @synchronized(self) {
        [self removeKeychainValueForKey:PBCrossSharedIDKey];
        [self removeKeychainValueForKey:PBCrossServerSharedIDKey];
        [self removeDefaultsValueForKey:PBCrossSharedIDKey];
        [self removeDefaultsValueForKey:PBCrossServerSharedIDKey];
        [self removeDefaultsValueForKey:[self remoteCacheKey]];
        [self removeDefaultsValueForKey:[self remoteRequestLogKey]];
        [self removeDefaultsKeysWithPrefix:[PBCrossRemoteCacheKeyPrefix stringByAppendingString:@"."]];
        [self removeDefaultsKeysWithPrefix:[PBCrossRemoteRequestLogKeyPrefix stringByAppendingString:@"."]];
        [self removeDefaultsValueForKey:PBCrossSystemUpdateHistoryKey];
    }
}


@end
