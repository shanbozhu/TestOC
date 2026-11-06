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
static NSString * const PBCrossLegacySystemUpdateHistoryKey = @"pb_system_update_history";
static NSString * const PBCrossRequestReservationLabel = @"com.pb.crossapp.remote-request-reservation.v1";
static NSString * const PBCrossRequestReservationPrefix = @"pb_remote_request_slot.";
static NSString * const PBCrossLocalPriorityMarker = @"pb.local-priority.v1";

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
@property (nonatomic, copy, nullable) NSString *defaultAccessGroup;
@property (nonatomic, copy, nullable) NSString *lastPrunedRequestDay;

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
    // Auxiliary data from different Keychain namespaces must never mix.
    NSData *scope = [NSJSONSerialization dataWithJSONObject:@[self.configuration.keychainService,
        self.configuration.keychainAccessGroup ?: @""] options:0 error:NULL];
    NSString *digest = [PBCrossCrypto MD5HexString:[[NSString alloc] initWithData:scope encoding:NSUTF8StringEncoding]];
    return [NSString stringWithFormat:@"pb_identity.%@.%@", digest, key];
}

- (nullable NSString *)defaultsStringForKey:(NSString *)key
{
    key = [self scopedDefaultsKey:key];
    // Absence in the shared domain means cleared, not "use a private old copy".
    NSUserDefaults *defaults = self.groupDefaults ?: self.standardDefaults;
    NSString *value = [defaults stringForKey:key];
    return value.length > 0 ? value : nil;
}

- (void)setDefaultsString:(NSString *)value forKey:(NSString *)key
{
    key = [self scopedDefaultsKey:key];
    if (value.length == 0) {
        [self.groupDefaults removeObjectForKey:key];
        [self.standardDefaults removeObjectForKey:key];
    } else {
        NSUserDefaults *defaults = self.groupDefaults ?: self.standardDefaults;
        [defaults setObject:value forKey:key];
        if (self.groupDefaults) { [self.standardDefaults removeObjectForKey:key]; }
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

- (nullable NSString *)resolvedAccessGroupWithError:(NSError **)error
{
    if (self.configuration.keychainAccessGroup.length > 0) { return self.configuration.keychainAccessGroup; }
    if (self.defaultAccessGroup) { return self.defaultAccessGroup; }

    // SecItemAdd alone uses the default group. Reads/updates/deletes without a
    // group search every accessible group, so discover it using a unique probe.
    NSDictionary *probe = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: [PBCrossDefaultKeychainService stringByAppendingString:@".group-probe"],
        (__bridge id)kSecAttrAccount: NSUUID.UUID.UUIDString,
        (__bridge id)kSecAttrSynchronizable: @NO,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        (__bridge id)kSecValueData: NSData.data,
        (__bridge id)kSecReturnAttributes: @YES,
    };
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)probe, &result);
    id attributes = CFBridgingRelease(result);
    if (status != errSecSuccess) {
        if (error) { *error = [self keychainErrorWithStatus:status key:@"default_access_group"]; }
        return nil;
    }
    NSString *group = [attributes isKindOfClass:NSDictionary.class] ? attributes[(__bridge id)kSecAttrAccessGroup] : nil;
    if (![group isKindOfClass:NSString.class] || group.length == 0) {
        if (error) { *error = [self keychainErrorWithStatus:errSecDecode key:@"default_access_group"]; }
        return nil; // Never try an unscoped cleanup if the system did not return a group.
    }
    NSDictionary *cleanup = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: probe[(__bridge id)kSecAttrService],
        (__bridge id)kSecAttrAccount: probe[(__bridge id)kSecAttrAccount],
        (__bridge id)kSecAttrAccessGroup: group,
        (__bridge id)kSecAttrSynchronizable: @NO,
    };
    status = SecItemDelete((__bridge CFDictionaryRef)cleanup);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        if (error) { *error = [self keychainErrorWithStatus:status key:@"default_access_group"]; }
        return nil;
    }
    self.defaultAccessGroup = group;
    return group;
}

- (nullable NSMutableDictionary<id, id> *)keychainQueryForKey:(nullable NSString *)key error:(NSError **)error
{
    NSString *accessGroup = [self resolvedAccessGroupWithError:error];
    if (!accessGroup) { return nil; }
    NSMutableDictionary<id, id> *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrService] = self.configuration.keychainService;
    if (key) { query[(__bridge id)kSecAttrAccount] = key; }
    query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
    query[(__bridge id)kSecAttrSynchronizable] = @NO;
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
    return [self keychainStringForKey:key serverIssued:NULL status:readStatus];
}

- (nullable NSString *)keychainStringForKey:(NSString *)key serverIssued:(BOOL *)serverIssued status:(OSStatus *)readStatus
{
    NSError *groupError = nil;
    NSMutableDictionary<id, id> *query = [self keychainQueryForKey:key error:&groupError];
    if (!query) { *readStatus = (OSStatus)groupError.code; return nil; }
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    id object = CFBridgingRelease(result);
    NSString *value = nil;
    if (status == errSecSuccess) {
        NSData *data = [object isKindOfClass:NSDictionary.class] ? object[(__bridge id)kSecValueData] : nil;
        if ([data isKindOfClass:NSData.class]) {
            value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        if (serverIssued && [object isKindOfClass:NSDictionary.class]) {
            NSData *marker = [PBCrossLocalPriorityMarker dataUsingEncoding:NSUTF8StringEncoding];
            *serverIssued = ![object[(__bridge id)kSecAttrGeneric] isEqual:marker];
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
                       key, self.configuration.keychainAccessGroup ?: self.defaultAccessGroup ?: @"-", (long)status);
        }
        return nil;
    }
    return value;
}

- (nullable NSString *)addKeychainStringIfAbsent:(NSString *)candidate
                                        forKey:(NSString *)key
                                         error:(NSError **)error
{
    NSMutableDictionary *query = [self keychainQueryForKey:key error:error];
    if (!query) { return nil; }
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

- (BOOL)writeKeychainString:(NSString *)value forKey:(NSString *)key
{
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return NO;
    }

    NSMutableDictionary *updateAttributes = [@{(__bridge id)kSecValueData: data} mutableCopy];
    if ([key isEqual:PBCrossServerSharedIDKey]) {
        updateAttributes[(__bridge id)kSecAttrGeneric] = NSData.data; // Explicit injection restores server priority.
    }
    NSMutableDictionary<id, id> *query = [self keychainQueryForKey:key error:NULL];
    if (!query) { return NO; }
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateAttributes);
    if (status == errSecSuccess) {
        return YES;
    }

    if (status == errSecItemNotFound) {
        NSMutableDictionary<id, id> *addQuery = [query mutableCopy];
        [addQuery addEntriesFromDictionary:updateAttributes];
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
               key, self.configuration.keychainAccessGroup ?: self.defaultAccessGroup ?: @"-", (long)status);
    return NO;
}

- (BOOL)removeKeychainValueForKey:(NSString *)key error:(NSError **)error
{
    NSMutableDictionary *query = [self keychainQueryForKey:key error:error];
    if (!query) { return NO; }
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status == errSecSuccess || status == errSecItemNotFound) { return YES; }
    if (error) { *error = [self keychainErrorWithStatus:status key:key]; }
    return NO;
}

#pragma mark - Shared ID

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

    // Keychain is the only persistent identity source. Ignore legacy Defaults
    // copies so a peer App cannot resurrect a cleared identity.
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
        OSStatus status = errSecSuccess;
        BOOL hasServerPriority = YES;
        NSString *serverSharedID = [self keychainStringForKey:PBCrossServerSharedIDKey serverIssued:&hasServerPriority status:&status];
        if (status != errSecSuccess && status != errSecItemNotFound) {
            if (error) { *error = [self keychainErrorWithStatus:status key:PBCrossServerSharedIDKey]; }
            return @"";
        }
        if (serverSharedID.length > 0) {
            if (serverIssued != NULL) {
                *serverIssued = hasServerPriority;
            }
            return serverSharedID;
        }

        NSString *sharedID = [self storedIDForKey:PBCrossSharedIDKey create:create error:&storageError];
        if (storageError) {
            if (error) { *error = storageError; }
            return @"";
        }

        return sharedID ?: @"";
    }
}

- (BOOL)setServerIssuedSharedID:(nullable NSString *)sharedID
{
    @synchronized(self) {
        if (sharedID.length == 0) {
            OSStatus readStatus = errSecSuccess;
            [self keychainStringForKey:PBCrossServerSharedIDKey status:&readStatus];
            if (readStatus != errSecSuccess && readStatus != errSecItemNotFound) { return NO; }
            NSMutableDictionary *query = [self keychainQueryForKey:PBCrossServerSharedIDKey error:NULL];
            if (!query) { return NO; }
            // Change priority in place without reading/copying/deleting the ID.
            // A peer injection before or after this atomic update keeps its value.
            NSDictionary *attributes = @{(__bridge id)kSecAttrGeneric:
                [PBCrossLocalPriorityMarker dataUsingEncoding:NSUTF8StringEncoding]};
            OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributes);
            if (status != errSecSuccess && status != errSecItemNotFound) { return NO; }
            return YES;
        }
        NSString *trimmed = [sharedID stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (!PBCrossIsValidSharedID(trimmed)) { return NO; }
        // One authoritative write: no second Keychain write can partially fail.
        if (![self writeKeychainString:trimmed forKey:PBCrossServerSharedIDKey]) { return NO; }
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
    return [self registerRemoteRequestIfAllowed:dailyLimit error:NULL];
}

- (BOOL)pruneRequestReservationsBeforeDay:(NSString *)today error:(NSError **)error
{
    if ([self.lastPrunedRequestDay isEqual:today]) { return YES; }
    NSMutableDictionary *query = [self keychainQueryForKey:nil error:error];
    if (!query) { return NO; }
    query[(__bridge id)kSecAttrLabel] = PBCrossRequestReservationLabel;
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    id records = CFBridgingRelease(result);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        if (error) { *error = [self keychainErrorWithStatus:status key:PBCrossRequestReservationLabel]; }
        return NO;
    }
    for (NSDictionary *record in [records isKindOfClass:NSArray.class] ? records : @[]) {
        NSString *account = record[(__bridge id)kSecAttrAccount];
        if (![account isKindOfClass:NSString.class] || ![account hasPrefix:PBCrossRequestReservationPrefix]) { continue; }
        NSArray *parts = [account componentsSeparatedByString:@"."];
        // pb_remote_request_slot.<service digest>.<YYYYMMDD>.<slot>
        if (parts.count == 4 && [parts[2] compare:today] == NSOrderedAscending) {
            NSMutableDictionary *deletion = [self keychainQueryForKey:account error:error];
            if (!deletion) { return NO; }
            deletion[(__bridge id)kSecAttrLabel] = PBCrossRequestReservationLabel;
            status = SecItemDelete((__bridge CFDictionaryRef)deletion);
            if (status != errSecSuccess && status != errSecItemNotFound) {
                if (error) { *error = [self keychainErrorWithStatus:status key:account]; }
                return NO;
            }
        }
    }
    self.lastPrunedRequestDay = today;
    return YES;
}

- (BOOL)registerRemoteRequestIfAllowed:(NSUInteger)dailyLimit error:(NSError **)error
{
    if (error) { *error = nil; }
    if (dailyLimit == 0) {
        return NO;
    }

    @synchronized(self) {
        NSString *today = PBCrossCurrentDayKey();
        if (![self pruneRequestReservationsBeforeDay:today error:error]) { return NO; }
        // Slots are the only quota authority. Old Defaults counters can differ
        // between Apps and cannot be merged atomically; the new quota starts
        // fresh on upgrade instead of importing a stale private count.
        for (NSUInteger slot = 0; slot < dailyLimit; slot++) {
            NSString *account = [NSString stringWithFormat:@"%@%@.%@.%lu", PBCrossRequestReservationPrefix,
                [self remoteServiceScope], today, (unsigned long)slot];
            NSMutableDictionary *reservation = [self keychainQueryForKey:account error:error];
            if (!reservation) { return NO; }
            reservation[(__bridge id)kSecAttrLabel] = PBCrossRequestReservationLabel;
            reservation[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
            reservation[(__bridge id)kSecValueData] = NSData.data;
            OSStatus status = SecItemAdd((__bridge CFDictionaryRef)reservation, NULL);
            if (status == errSecSuccess) { return YES; }
            if (status != errSecDuplicateItem) {
                if (error) { *error = [self keychainErrorWithStatus:status key:account]; }
                return NO;
            }
        }
        return NO;
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
        NSError *reservationError = nil;
        NSMutableDictionary *reservations = [self keychainQueryForKey:nil error:&reservationError];
        BOOL reservationsRemoved = NO;
        if (reservations) {
            reservations[(__bridge id)kSecAttrLabel] = PBCrossRequestReservationLabel;
            OSStatus status = SecItemDelete((__bridge CFDictionaryRef)reservations);
            reservationsRemoved = status == errSecSuccess || status == errSecItemNotFound;
            if (!reservationsRemoved) {
                reservationError = [self keychainErrorWithStatus:status key:PBCrossRequestReservationLabel];
            }
        }
        if (error) { *error = sharedError ?: serverError ?: reservationError; }
        // Remove scoped mirrors left by previous SDK releases; never recreate them.
        [self removeDefaultsValueForKey:PBCrossSharedIDKey];
        [self removeDefaultsValueForKey:PBCrossServerSharedIDKey];
        [self removeDefaultsValueForKey:[self remoteCacheKey]];
        [self removeDefaultsValueForKey:[self remoteRequestLogKey]];
        [self removeDefaultsKeysWithPrefix:[PBCrossRemoteCacheKeyPrefix stringByAppendingString:@"."]];
        [self removeDefaultsKeysWithPrefix:[PBCrossRemoteRequestLogKeyPrefix stringByAppendingString:@"."]];
        // Cleanup only: system update history is no longer read or written.
        [self removeDefaultsValueForKey:PBCrossLegacySystemUpdateHistoryKey];
        return sharedRemoved && serverRemoved && reservationsRemoved;
    }
}


@end
