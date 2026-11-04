// Exercise the real comparison helper without UIKit, ATT, DeviceCheck or Keychain access.
#import "PBUniqueIdentifierHelper.h"
#import "PBDeviceIdentityStorage.h"
#import <Security/Security.h>
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <DeviceCheck/DeviceCheck.h>
#import <ifaddrs.h>
#import <net/if_dl.h>
#import <sys/socket.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

static ATTrackingManagerAuthorizationStatus CRStatus;
static BOOL CRZeroIDFA;
static NSUInteger CRAdvertisingReads;

// Isolated Keychain fixture: omitted group searches all accessible groups.
static NSMutableDictionary<NSString *, NSData *> *CRRecords;
static NSString * const CRDefaultGroup = @"TEAM.test.default";
static OSStatus CRAddError, CRDeleteError, CRReadError;
static BOOL CROmitProbeGroup;
static NSUInteger CRUnscopedQueries;
static NSString *CRKey(NSDictionary *query) {
    return [NSString stringWithFormat:@"%@/%@/%@", query[(__bridge id)kSecAttrService],
        query[(__bridge id)kSecAttrAccessGroup] ?: CRDefaultGroup, query[(__bridge id)kSecAttrAccount]];
}
static NSArray<NSString *> *CRMatches(NSDictionary *query) {
    NSMutableArray *matches = [NSMutableArray array];
    for (NSString *key in CRRecords) {
        NSArray *parts = [key componentsSeparatedByString:@"/"];
        if (![parts[0] isEqual:query[(__bridge id)kSecAttrService]] ||
            ![parts[2] isEqual:query[(__bridge id)kSecAttrAccount]]) { continue; }
        NSString *group = query[(__bridge id)kSecAttrAccessGroup];
        if (!group || [parts[1] isEqual:group]) { [matches addObject:key]; }
    }
    return [matches sortedArrayUsingSelector:@selector(compare:)];
}
OSStatus SecItemCopyMatching(CFDictionaryRef raw, CFTypeRef *result) {
    NSDictionary *query = (__bridge NSDictionary *)raw;
    if (!query[(__bridge id)kSecAttrAccessGroup]) { CRUnscopedQueries++; }
    if (CRReadError) { return CRReadError; }
    NSString *key = CRMatches(query).firstObject;
    if (!key) { return errSecItemNotFound; }
    if (result) { *result = CFBridgingRetain(CRRecords[key]); }
    return errSecSuccess;
}
OSStatus SecItemAdd(CFDictionaryRef raw, CFTypeRef *result) {
    NSDictionary *query = (__bridge NSDictionary *)raw;
    if (CRAddError) { return CRAddError; }
    NSString *key = CRKey(query);
    if (CRRecords[key]) { return errSecDuplicateItem; }
    CRRecords[key] = query[(__bridge id)kSecValueData];
    if (result) {
        NSMutableDictionary *attributes = [query mutableCopy];
        if (!CROmitProbeGroup) { attributes[(__bridge id)kSecAttrAccessGroup] = CRDefaultGroup; }
        *result = CFBridgingRetain(attributes);
    }
    return errSecSuccess;
}
OSStatus SecItemDelete(CFDictionaryRef raw) {
    NSDictionary *query = (__bridge NSDictionary *)raw;
    if (!query[(__bridge id)kSecAttrAccessGroup]) { CRUnscopedQueries++; }
    if (CRDeleteError) { return CRDeleteError; }
    NSArray *matches = CRMatches(query);
    [CRRecords removeObjectsForKeys:matches];
    return matches.count ? errSecSuccess : errSecItemNotFound;
}

// Model valid and truncated AF_LINK records, including a cellular interface
// with sdl_alen=0. Allocations end exactly at sdl_len so ASan detects overreads.
static NSUInteger CRMACFixture;
int getifaddrs(struct ifaddrs **list) {
    struct ifaddrs *entry = calloc(1, sizeof(struct ifaddrs));
    BOOL valid = CRMACFixture == 0;
    size_t header = offsetof(struct sockaddr_dl, sdl_data);
    const char *name = valid ? "en0" : "pdp_ip0";
    size_t nameLength = strlen(name);
    size_t length = CRMACFixture == 2 ? 2 : header + nameLength + (valid ? 6 : CRMACFixture == 3 ? 2 : 0);
    struct sockaddr_dl *link = calloc(1, length);
    link->sdl_len = (uint8_t)length; link->sdl_family = AF_LINK;
    if (length >= header) {
        link->sdl_nlen = (uint8_t)nameLength;
        link->sdl_alen = valid || CRMACFixture == 3 ? 6 : 0;
        memcpy(link->sdl_data, name, nameLength);
        if (valid) { memcpy(LLADDR(link), "\x01\x23\x45\x67\x89\xab", 6); }
    }
    entry->ifa_name = strdup(name); entry->ifa_addr = (struct sockaddr *)link;
    *list = entry;
    return 0;
}
void freeifaddrs(struct ifaddrs *list) {
    free(list->ifa_addr); free(list->ifa_name); free(list);
}

static int CRCheck(BOOL passed, const char *name) {
    printf("%s %s\n", passed ? "PASS" : "FAIL", name);
    return passed ? 0 : 1;
}
static PBDeviceIdentityStorage *CRStorage(void) {
    return [[PBDeviceIdentityStorage alloc] initWithNamespace:@"cr.app.identity"
        directoryURL:[NSURL fileURLWithPath:@"/tmp/unused-identity-fixture"]];
}
static int CRVerifyStorageAndMAC(void) {
    int failures = 0;
    CRRecords = [NSMutableDictionary dictionary];
    NSString *localKey = [NSString stringWithFormat:@"cr.app.identity/%@/app_device_id", CRDefaultGroup];
    NSString *sharedKey = @"cr.app.identity/AAA.shared/app_device_id";
    NSData *shared = [@"22222222-2222-4222-8222-222222222222" dataUsingEncoding:NSUTF8StringEncoding];
    CRRecords[sharedKey] = shared;
    PBUniqueIdentifierItem *item = [PBUniqueIdentifierItem itemWithSchemeType:PBUniqueIdentifierSchemeTypeKeychainUUID];
    for (NSUInteger failure = 0; failure < 3; failure++) {
        CRAddError = failure == 0 ? errSecInteractionNotAllowed : 0;
        CROmitProbeGroup = failure == 1;
        CRDeleteError = failure == 2 ? errSecInteractionNotAllowed : 0;
        PBDeviceIdentityStorage *storage = CRStorage();
        NSError *error = nil;
        failures += CRCheck(![storage appDeviceIdentifierWithError:&error] && error &&
            ![storage removeAppDeviceIdentifierWithError:&error] && CRRecords[sharedKey] && CRUnscopedQueries == 0,
            "default-group resolution failures cannot read/create/delete identities in other groups");
        [PBUniqueIdentifierHelper refreshIdentifierForItem:item completion:nil];
        failures += CRCheck(item.identifierError.length > 0 && !item.isIdentifierCopyable && CRUnscopedQueries == 0,
            "comparison helper fails closed when default-group resolution fails");
    }
    CRAddError = CRDeleteError = 0; CROmitProbeGroup = NO;
    PBDeviceIdentityStorage *storage = CRStorage();
    NSError *error = nil;
    NSString *created = [storage appDeviceIdentifierWithError:&error];
    failures += CRCheck(created.length && ![created isEqual:@"22222222-2222-4222-8222-222222222222"] &&
        CRRecords[localKey] && !error && [[CRStorage() appDeviceIdentifierWithError:NULL] isEqual:created],
        "local identity is created/read only in the resolved default group");
    failures += CRCheck([storage removeAppDeviceIdentifierWithError:&error] && !error &&
        !CRRecords[localKey] && [CRRecords[sharedKey] isEqual:shared] && CRUnscopedQueries == 0,
        "local identity reset preserves accessible shared-group records");
    CRReadError = errSecInteractionNotAllowed;
    failures += CRCheck(![storage appDeviceIdentifierWithError:&error] && error.code == CRReadError && !CRRecords[localKey],
        "local identity read errors do not create a replacement");
    CRReadError = 0;
    NSString *helperSharedKey = @"com.damaiios.PBUniqueIdentifier/AAA.shared/device_uuid";
    CRRecords[helperSharedKey] = shared;
    [PBUniqueIdentifierHelper refreshIdentifierForItem:item completion:nil];
    NSString *helperValue = item.identifierValue;
    [PBUniqueIdentifierHelper refreshIdentifierForItem:item completion:nil];
    failures += CRCheck(helperValue.length && ![helperValue isEqual:@"22222222-2222-4222-8222-222222222222"] &&
        [item.identifierValue isEqual:helperValue] && !item.identifierError && CRRecords[helperSharedKey] && CRUnscopedQueries == 0,
        "comparison helper creates and rereads its default-group ID without reading shared groups");
    PBUniqueIdentifierItem *mac = [PBUniqueIdentifierItem itemWithSchemeType:PBUniqueIdentifierSchemeTypeMACAddress];
    for (CRMACFixture = 0; CRMACFixture < 4; CRMACFixture++) {
        [PBUniqueIdentifierHelper refreshIdentifierForItem:mac completion:nil];
        failures += CRCheck(CRMACFixture == 0 ? [mac.identifierValue hasPrefix:@"01:23:45:67:89:AB"] :
            [mac.identifierValue hasPrefix:@"无法获取"], "MAC extraction bounds valid, absent and truncated link-layer addresses");
    }
    return failures;
}

@implementation UIDevice
+ (UIDevice *)currentDevice { return [self new]; }
- (NSUUID *)identifierForVendor { return nil; }
@end
@implementation ASIdentifierManager
+ (ASIdentifierManager *)sharedManager { return [self new]; }
- (BOOL)advertisingTrackingEnabled { return YES; }
- (NSUUID *)advertisingIdentifier {
    CRAdvertisingReads++;
    return [[NSUUID alloc] initWithUUIDString:CRZeroIDFA ? @"00000000-0000-0000-0000-000000000000"
        : @"6ABF0056-2C6A-4378-9E80-9143C2669683"];
}
@end
@implementation ATTrackingManager
+ (ATTrackingManagerAuthorizationStatus)trackingAuthorizationStatus { return CRStatus; }
+ (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(ATTrackingManagerAuthorizationStatus))completion {
    completion(CRStatus);
}
@end
@implementation DCDevice
+ (DCDevice *)currentDevice { return [self new]; }
- (BOOL)isSupported { return NO; }
- (void)generateTokenWithCompletionHandler:(void (^)(NSData *, NSError *))completion { completion(nil, nil); }
@end

int main(void) { @autoreleasepool {
    int failures = CRVerifyStorageAndMAC();
    PBUniqueIdentifierItem *item = [PBUniqueIdentifierItem itemWithSchemeType:PBUniqueIdentifierSchemeTypeIDFA];
    for (NSNumber *status in @[@3, @2, @1, @0, @3]) {
        CRStatus = status.integerValue;
        NSUInteger before = CRAdvertisingReads;
        __block BOOL completed = NO;
        [PBUniqueIdentifierHelper refreshIdentifierForItem:item completion:^{ completed = YES; }];
        BOOL authorized = CRStatus == ATTrackingManagerAuthorizationStatusAuthorized;
        BOOL passed = completed && item.isIdentifierCopyable == authorized;
        if (!authorized) {
            passed = passed && ![[NSUUID alloc] initWithUUIDString:item.identifierValue] && before == CRAdvertisingReads;
        }
        printf("%s comparison refresh/copy eligibility follows current ATT status %ld\n", passed ? "PASS" : "FAIL", (long)CRStatus);
        if (!passed) { failures++; }
    }
    CRZeroIDFA = YES;
    [PBUniqueIdentifierHelper refreshIdentifierForItem:item completion:nil];
    printf("%s zero IDFA is never copyable\n", !item.isIdentifierCopyable ? "PASS" : "FAIL");
    return failures || item.isIdentifierCopyable;
}}
