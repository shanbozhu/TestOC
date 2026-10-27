#import "PBDeviceIdentityStorage.h"
#import <Security/Security.h>

static NSString * const PBIdentityStorageErrorDomain = @"PBDeviceIdentityStorage";

@interface PBDeviceIdentityStorage ()
@property (nonatomic, copy) NSString *namespace;
@property (nonatomic, strong) NSURL *directoryURL;
@end

@implementation PBDeviceIdentityStorage

- (instancetype)initWithNamespace:(NSString *)namespace directoryURL:(NSURL *)directoryURL {
    NSParameterAssert(namespace.length > 0);
    NSParameterAssert(directoryURL.isFileURL);
    self = [super init];
    if (self) {
        _namespace = [namespace copy];
        _directoryURL = directoryURL;
    }
    return self;
}

- (NSMutableDictionary *)keychainQuery {
    // No accessGroup: use the host app's default Keychain group, never an SDK-wide group.
    return [@{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
              (__bridge id)kSecAttrService: self.namespace,
              (__bridge id)kSecAttrAccount: @"app_device_id",
              (__bridge id)kSecAttrSynchronizable: @NO} mutableCopy];
}

- (NSError *)keychainError:(OSStatus)status {
    NSString *message = CFBridgingRelease(SecCopyErrorMessageString(status, NULL));
    return [NSError errorWithDomain:NSOSStatusErrorDomain code:status
                          userInfo:@{NSLocalizedDescriptionKey: message ?: @"Keychain 操作失败"}];
}

- (nullable NSString *)identifierFromData:(NSData *)data error:(NSError **)error {
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSUUID *uuid = value ? [[NSUUID alloc] initWithUUIDString:value] : nil;
    if (!uuid || [uuid.UUIDString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        if (error) {
            *error = [NSError errorWithDomain:PBIdentityStorageErrorDomain code:1
                                    userInfo:@{NSLocalizedDescriptionKey: @"已存标识损坏；保留原记录，请显式重置后重试"}];
        }
        return nil;
    }
    return uuid.UUIDString.lowercaseString;
}

- (nullable NSString *)readKeychainIdentifierWithStatus:(OSStatus *)status error:(NSError **)error {
    NSMutableDictionary *query = [self keychainQuery];
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    CFTypeRef result = NULL;
    *status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    id object = CFBridgingRelease(result);
    if (*status != errSecSuccess) {
        if (*status != errSecItemNotFound && error) {
            *error = [self keychainError:*status];
        }
        return nil;
    }
    return [self identifierFromData:[object isKindOfClass:NSData.class] ? object : NSData.data error:error];
}

- (nullable NSString *)appDeviceIdentifierWithError:(NSError **)error {
    @synchronized (self) {
        OSStatus status = errSecSuccess;
        NSString *existing = [self readKeychainIdentifierWithStatus:&status error:error];
        if (status != errSecItemNotFound) {
            // Includes protected/unavailable Keychain AND corrupt records: never regenerate.
            return existing;
        }
        NSString *candidate = NSUUID.UUID.UUIDString.lowercaseString;
        NSMutableDictionary *item = [self keychainQuery];
        item[(__bridge id)kSecValueData] = [candidate dataUsingEncoding:NSUTF8StringEncoding];
        item[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
        status = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
        if (status == errSecSuccess) {
            return candidate;
        }
        if (status == errSecDuplicateItem) {
            // Another creator won. Return the persisted winner, never our unsaved candidate.
            NSString *winner = [self readKeychainIdentifierWithStatus:&status error:error];
            if (!winner && status == errSecItemNotFound && error) {
                *error = [self keychainError:status];
            }
            return winner;
        }
        if (error) {
            *error = [self keychainError:status];
        }
        return nil;
    }
}

- (NSURL *)installationURL {
    return [self.directoryURL URLByAppendingPathComponent:@"installation_id.txt" isDirectory:NO];
}

- (BOOL)prepareDirectoryWithError:(NSError **)error {
    NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication};
    if (![NSFileManager.defaultManager createDirectoryAtURL:self.directoryURL
                               withIntermediateDirectories:YES attributes:attributes error:error]) {
        return NO;
    }
    return [self.directoryURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:error];
}

- (nullable NSString *)installationIdentifierWithError:(NSError **)error {
    @synchronized (self) {
        if (![self prepareDirectoryWithError:error]) {
            return nil;
        }
        NSError *readError = nil;
        NSData *data = [NSData dataWithContentsOfURL:self.installationURL options:0 error:&readError];
        if (data) {
            if (![self.installationURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:error]) {
                return nil;
            }
            return [self identifierFromData:data error:error];
        }
        BOOL missing = [readError.domain isEqualToString:NSCocoaErrorDomain] &&
                       (readError.code == NSFileReadNoSuchFileError || readError.code == NSFileNoSuchFileError);
        if (!missing) {
            if (error) { *error = readError; }
            return nil;
        }
        NSString *candidate = NSUUID.UUID.UUIDString.lowercaseString;
        NSData *newData = [candidate dataUsingEncoding:NSUTF8StringEncoding];
        NSDataWritingOptions options = NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUntilFirstUserAuthentication;
        if (![newData writeToURL:self.installationURL options:options error:error]) {
            return nil;
        }
        if (![self.installationURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:error]) {
            return nil;
        }
        return candidate;
    }
}

- (BOOL)removeAppDeviceIdentifierWithError:(NSError **)error {
    @synchronized (self) {
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)[self keychainQuery]);
        if (status == errSecSuccess || status == errSecItemNotFound) { return YES; }
        if (error) { *error = [self keychainError:status]; }
        return NO;
    }
}

- (BOOL)removeInstallationIdentifierWithError:(NSError **)error {
    @synchronized (self) {
        NSError *removeError = nil;
        if ([NSFileManager.defaultManager removeItemAtURL:self.installationURL error:&removeError]) { return YES; }
        if ([removeError.domain isEqualToString:NSCocoaErrorDomain] &&
            (removeError.code == NSFileNoSuchFileError || removeError.code == NSFileReadNoSuchFileError)) { return YES; }
        if (error) { *error = removeError; }
        return NO;
    }
}

@end
