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

- (NSString *)scopedDefaultsKey:(NSString *)key
{
    // Mirrors from different Keychain namespaces must never mix.
    NSData *scope = [NSJSONSerialization dataWithJSONObject:@[self.configuration.keychainService,
        self.configuration.keychainAccessGroup ?: @""] options:0 error:NULL];
    NSString *digest = [PBCrossCrypto MD5HexString:[[NSString alloc] initWithData:scope encoding:NSUTF8StringEncoding]];
    return [NSString stringWithFormat:@"pb_identity.%@.%@", digest, key];
}

- (nullable NSString *)defaultsStringForKey:(NSString *)key
{
    key = [self scopedDefaultsKey:key];
    NSString *value = [self.groupDefaults stringForKey:key];
    if (value.length == 0) {
        value = [self.standardDefaults stringForKey:key];
    }
    return value.length > 0 ? value : nil;
}

- (void)setDefaultsString:(NSString *)value forKey:(NSString *)key
{
    key = [self scopedDefaultsKey:key];
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
    key = [self scopedDefaultsKey:key];
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

- (NSError *)keychainErrorWithStatus:(OSStatus)status key:(NSString *)key
{
    NSString *message = CFBridgingRelease(SecCopyErrorMessageString(status, NULL));
    return [NSError errorWithDomain:NSOSStatusErrorDomain code:status
                          userInfo:@{NSLocalizedDescriptionKey:
        [NSString stringWithFormat:@"Keychain 标识不可用（%@）：%@", key, message ?: @"操作失败"]}];
}

- (nullable NSString *)keychainStringForKey:(NSString *)key status:(OSStatus *)readStatus
{
    NSString *accessGroup = self.configuration.keychainAccessGroup;
    NSMutableDictionary<id, id> *query = [self keychainQueryForKey:key accessGroup:accessGroup];
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    id object = CFBridgingRelease(result);
    NSString *value = nil;
    if (status == errSecSuccess) {
        if ([object isKindOfClass:[NSData class]]) {
            value = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        }
        // 损坏记录也不等于不存在，保留原记录等待显式处理。
        if (!PBCrossIsValidSharedID(value)) {
            status = errSecDecode;
        }
    }
    *readStatus = status;
    if (status != errSecSuccess) {
        if (status != errSecItemNotFound) {
            PBCrossLog(self.configuration, @"Keychain 读取失败 account=%@ group=%@ status=%ld",
                       key, accessGroup ?: @"-", (long)status);
        }
        return nil;
    }
    return value;
}

- (nullable NSString *)addKeychainStringIfAbsent:(NSString *)candidate
                                        forKey:(NSString *)key
                                         error:(NSError **)error
{
    NSMutableDictionary *query = [self keychainQueryForKey:key accessGroup:self.configuration.keychainAccessGroup];
    query[(__bridge id)kSecValueData] = [candidate dataUsingEncoding:NSUTF8StringEncoding];
    query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
    query[(__bridge id)kSecAttrSynchronizable] = @NO;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess) {
        return candidate;
    }
    if (status == errSecDuplicateItem) {
        // 其他 App/进程已创建：返回持久化的胜出值，绝不覆盖它。
        NSString *winner = [self keychainStringForKey:key status:&status];
        if (winner) {
            return winner;
        }
    }
    if (error) {
        *error = [self keychainErrorWithStatus:status key:key];
    }
    return nil;
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

- (BOOL)removeKeychainValueForKey:(NSString *)key error:(NSError **)error
{
    NSMutableDictionary *query = [self keychainQueryForKey:key accessGroup:self.configuration.keychainAccessGroup];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status == errSecSuccess || status == errSecItemNotFound) { return YES; }
    if (error) { *error = [self keychainErrorWithStatus:status key:key]; }
    return NO;
}

- (BOOL)writeKeychainString:(NSString *)value forKey:(NSString *)key
{
    return [self writeKeychainString:value forKey:key accessGroup:self.configuration.keychainAccessGroup];
}

#pragma mark - Shared ID

- (void)mirrorSharedID:(NSString *)sharedID
{
    NSString *defaultsValue = [self defaultsStringForKey:PBCrossSharedIDKey];
    if (![defaultsValue isEqualToString:sharedID]) {
        [self setDefaultsString:sharedID forKey:PBCrossSharedIDKey];
    }
}

- (nullable NSString *)storedIDForKey:(NSString *)key create:(BOOL)create error:(NSError **)error
{
    OSStatus status = errSecSuccess;
    NSString *stored = [self keychainStringForKey:key status:&status];
    if (status == errSecSuccess) {
        return stored;
    }
    if (status != errSecItemNotFound) {
        if (error) {
            *error = [self keychainErrorWithStatus:status key:key];
        }
        return nil;
    }

    // Defaults are mirrors only. A peer App may still hold a pre-reset mirror;
    // never resurrect it when the authoritative Keychain record is absent.
    if (!create) { return nil; }
    return [self addKeychainStringIfAbsent:[PBCrossCrypto randomUUIDString] forKey:key error:error];
}

- (NSString *)sharedIDCreatingIfNeeded:(BOOL)create
                        serverIssued:(nullable BOOL *)serverIssued
                               error:(NSError **)error
{
    @synchronized(self) {
        if (error) {
            *error = nil;
        }
        if (serverIssued != NULL) {
            *serverIssued = NO;
        }

        NSError *storageError = nil;
        NSString *serverSharedID = [self storedIDForKey:PBCrossServerSharedIDKey create:NO error:&storageError];
        if (storageError) {
            if (error) { *error = storageError; }
            return @"";
        }
        if (serverSharedID.length > 0) {
            if (serverIssued != NULL) {
                *serverIssued = YES;
            }
            [self mirrorSharedID:serverSharedID];
            return serverSharedID;
        }

        NSString *sharedID = [self storedIDForKey:PBCrossSharedIDKey create:create error:&storageError];
        if (storageError) {
            if (error) { *error = storageError; }
            return @"";
        }

        if (sharedID.length > 0) {
            [self mirrorSharedID:sharedID];
        }
        return sharedID ?: @"";
    }
}

- (BOOL)setServerIssuedSharedID:(nullable NSString *)sharedID
{
    @synchronized(self) {
        if (sharedID.length == 0) {
            OSStatus status = errSecSuccess;
            NSString *serverID = [self keychainStringForKey:PBCrossServerSharedIDKey status:&status];
            if (status != errSecSuccess && status != errSecItemNotFound) { return NO; }
            // Preserve the last effective ID before removing the server priority.
            // A failed copy/delete leaves the authoritative server ID unchanged.
            if (serverID && ![self writeKeychainString:serverID forKey:PBCrossSharedIDKey]) { return NO; }
            if (![self removeKeychainValueForKey:PBCrossServerSharedIDKey error:NULL]) { return NO; }
            [self removeDefaultsValueForKey:PBCrossServerSharedIDKey];
            if (serverID) { [self mirrorSharedID:serverID]; }
            return YES;
        }
        NSString *trimmed = [sharedID stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (!PBCrossIsValidSharedID(trimmed)) { return NO; }
        // One authoritative write: no second Keychain write can partially fail.
        if (![self writeKeychainString:trimmed forKey:PBCrossServerSharedIDKey]) { return NO; }
        [self setDefaultsString:trimmed forKey:PBCrossServerSharedIDKey];
        [self mirrorSharedID:trimmed];
        return YES;
    }
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
    prefix = [self scopedDefaultsKey:prefix];
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
            [self.groupDefaults removeObjectForKey:key];
            [self.standardDefaults removeObjectForKey:key];
        }
    }
}

- (void)clearStoredIdentity
{
    [self clearStoredIdentityWithError:NULL];
}

- (BOOL)clearStoredIdentityWithError:(NSError **)error
{
    @synchronized(self) {
        NSError *sharedError = nil;
        NSError *serverError = nil;
        BOOL sharedRemoved = [self removeKeychainValueForKey:PBCrossSharedIDKey error:&sharedError];
        BOOL serverRemoved = [self removeKeychainValueForKey:PBCrossServerSharedIDKey error:&serverError];
        if (error) { *error = sharedError ?: serverError; }
        [self removeDefaultsValueForKey:PBCrossSharedIDKey];
        [self removeDefaultsValueForKey:PBCrossServerSharedIDKey];
        [self removeDefaultsValueForKey:[self remoteCacheKey]];
        [self removeDefaultsValueForKey:[self remoteRequestLogKey]];
        [self removeDefaultsKeysWithPrefix:[PBCrossRemoteCacheKeyPrefix stringByAppendingString:@"."]];
        [self removeDefaultsKeysWithPrefix:[PBCrossRemoteRequestLogKeyPrefix stringByAppendingString:@"."]];
        [self removeDefaultsValueForKey:PBCrossSystemUpdateHistoryKey];
        return sharedRemoved && serverRemoved;
    }
}


@end
