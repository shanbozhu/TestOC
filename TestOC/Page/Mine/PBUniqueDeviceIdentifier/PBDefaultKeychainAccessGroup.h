#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

/// Only SecItemAdd selects the default group when accessGroup is omitted.
/// Resolve it with a unique probe; never issue an unscoped read or delete.
static inline NSString * _Nullable PBResolveDefaultKeychainAccessGroup(NSString *service,
                                                                      NSError **error) {
    NSDictionary *probe = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: [service stringByAppendingString:@".group-probe"],
        (__bridge id)kSecAttrAccount: NSUUID.UUID.UUIDString,
        (__bridge id)kSecAttrSynchronizable: @NO,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        (__bridge id)kSecValueData: NSData.data,
        (__bridge id)kSecReturnAttributes: @YES,
    };
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)probe, &result);
    id attributes = CFBridgingRelease(result);
    NSString *group = [attributes isKindOfClass:NSDictionary.class] ? attributes[(__bridge id)kSecAttrAccessGroup] : nil;
    if (status == errSecSuccess) {
        if (![group isKindOfClass:NSString.class] || group.length == 0) {
            status = errSecDecode;
        } else {
            NSDictionary *cleanup = @{
                (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                (__bridge id)kSecAttrService: probe[(__bridge id)kSecAttrService],
                (__bridge id)kSecAttrAccount: probe[(__bridge id)kSecAttrAccount],
                (__bridge id)kSecAttrAccessGroup: group,
                (__bridge id)kSecAttrSynchronizable: @NO,
            };
            status = SecItemDelete((__bridge CFDictionaryRef)cleanup);
            if (status == errSecSuccess || status == errSecItemNotFound) { return group; }
        }
    }
    if (error) {
        NSString *message = CFBridgingRelease(SecCopyErrorMessageString(status, NULL));
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:@{
            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"无法确定默认 Keychain 组：%@", message ?: @"操作失败"]
        }];
    }
    return nil;
}

NS_ASSUME_NONNULL_END
