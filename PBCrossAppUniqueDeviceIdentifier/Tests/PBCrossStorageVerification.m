#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <objc/runtime.h>
#import "PBCrossIdentityStore.h"
#import "PBCrossAppUniqueDeviceIdentifierManager.h"
#import "PBCrossDeviceAttributeCollector.h"
#import "PBCrossIdentityGenerator.h"
#import "PBCrossRemoteResolver.h"

static NSString * const CRSharedKey = @"pb_shared_id";
static NSString * const CRServerKey = @"pb_server_shared_id";
static NSObject *CRLock;
static NSMutableDictionary<NSString *, id> *CRRecords;
static NSMutableDictionary<NSString *, NSNumber *> *CRReadErrors;
static OSStatus CRAddError;
static NSMutableDictionary<NSString *, NSNumber *> *CRWriteErrors;
static OSStatus CRDeleteError;
static OSStatus CRReservationDeleteError;
static NSMutableDictionary<NSString *, NSMutableDictionary *> *CRAttributes;
static NSString * const CRDefaultGroup = @"TEAM.cr.default";
static BOOL CRProbeOmitsGroup, CRBlockPriorityUpdate;
static dispatch_semaphore_t CRPriorityReady, CRPriorityRelease;
static dispatch_semaphore_t CRSlotReady, CRSlotRelease;
static NSUInteger CRSlotArrivals;

@interface PBCrossIdentityStore (Verification)
- (NSString *)scopedDefaultsKey:(NSString *)key;
- (NSString *)remoteRequestLogKey;
- (NSString *)remoteServiceScope;
@end
@interface PBCrossRemoteResolver (Verification)
- (void)handleResponseData:(NSData *)data response:(NSURLResponse *)response networkError:(NSError *)error
               completion:(PBCrossRemoteResolutionCompletion)completion;
@end
static NSUInteger CRAdds, CRUpdates, CRPrivateQueries;
static BOOL CRInjectDuplicate, CRFailWinnerRead;
static dispatch_semaphore_t CRRaceReady, CRRaceRelease;
static NSUInteger CRRaceReaders;
static int CRFailures;
static NSInteger CRTrackingStatus = 3;
static BOOL CRAdvertisingFixture;
static NSString *CRSystemUpdateFixture;
static NSUInteger CRCollections;
static dispatch_semaphore_t CRCollectionReady, CRCollectionRelease;

@interface ATTrackingManager : NSObject
+ (NSInteger)trackingAuthorizationStatus;
@end
@implementation ATTrackingManager
+ (NSInteger)trackingAuthorizationStatus { return CRTrackingStatus; }
@end

static NSString *CRRecordKey(NSDictionary *query)
{
    NSString *group = query[(__bridge id)kSecAttrAccessGroup] ?: CRDefaultGroup;
    return [NSString stringWithFormat:@"%@/%@/%@", query[(__bridge id)kSecAttrService],
            group, query[(__bridge id)kSecAttrAccount]];
}

static NSArray<NSString *> *CRMatchingRecords(NSDictionary *query)
{
    NSMutableArray *matches = [NSMutableArray array];
    for (NSString *key in CRRecords.allKeys) {
        NSArray *parts = [key componentsSeparatedByString:@"/"];
        if (parts.count != 3 || ![parts[0] isEqual:query[(__bridge id)kSecAttrService]]) { continue; }
        NSString *group = query[(__bridge id)kSecAttrAccessGroup];
        NSString *account = query[(__bridge id)kSecAttrAccount];
        if (group && ![group isEqual:parts[1]]) { continue; }
        if (account && ![account isEqual:parts[2]]) { continue; }
        id label = query[(__bridge id)kSecAttrLabel];
        if (label && ![label isEqual:CRAttributes[key][(__bridge id)kSecAttrLabel]]) { continue; }
        [matches addObject:key];
    }
    return [matches sortedArrayUsingSelector:@selector(compare:)];
}

static NSDictionary *CRReturnedAttributes(NSString *key, BOOL includingData)
{
    NSArray *parts = [key componentsSeparatedByString:@"/"];
    NSMutableDictionary *attributes = [CRAttributes[key] mutableCopy] ?: [NSMutableDictionary dictionary];
    attributes[(__bridge id)kSecAttrService] = parts[0];
    attributes[(__bridge id)kSecAttrAccessGroup] = parts[1];
    attributes[(__bridge id)kSecAttrAccount] = parts[2];
    if (includingData) { attributes[(__bridge id)kSecValueData] = CRRecords[key]; }
    else { [attributes removeObjectForKey:(__bridge id)kSecValueData]; }
    return attributes;
}

// Match actual SecItem semantics: omitting a group searches all accessible
// groups; only SecItemAdd assigns the default group. No real Keychain is used.
OSStatus SecItemCopyMatching(CFDictionaryRef rawQuery, CFTypeRef *result)
{
    NSDictionary *query = (__bridge NSDictionary *)rawQuery;
    NSString *account = query[(__bridge id)kSecAttrAccount];
    BOOL waitForPeer = NO;
    @synchronized(CRLock) {
        if (!query[(__bridge id)kSecAttrAccessGroup]) { CRPrivateQueries++; }
        NSNumber *failure = account ? CRReadErrors[account] : nil;
        if (failure) { return failure.intValue; }
        NSArray *matches = CRMatchingRecords(query);
        if (matches.count) {
            BOOL all = [query[(__bridge id)kSecMatchLimit] isEqual:(__bridge id)kSecMatchLimitAll];
            BOOL attributes = [query[(__bridge id)kSecReturnAttributes] boolValue];
            BOOL data = [query[(__bridge id)kSecReturnData] boolValue];
            NSMutableArray *values = [NSMutableArray array];
            for (NSString *key in matches) {
                [values addObject:attributes ? CRReturnedAttributes(key, data) : CRRecords[key]];
                if (!all) { break; }
            }
            if (result) { *result = CFBridgingRetain(all ? values : values.firstObject); }
            return errSecSuccess;
        }
        if (CRRaceReady && [account isEqualToString:CRSharedKey] && CRRaceReaders < 2) {
            CRRaceReaders++;
            waitForPeer = YES;
        }
    }
    if (waitForPeer) {
        dispatch_semaphore_signal(CRRaceReady);
        dispatch_semaphore_wait(CRRaceRelease, DISPATCH_TIME_FOREVER);
    }
    return errSecItemNotFound;
}

OSStatus SecItemAdd(CFDictionaryRef rawQuery, CFTypeRef *result)
{
    NSDictionary *query = (__bridge NSDictionary *)rawQuery;
    BOOL blockSlot = NO;
    @synchronized(CRLock) {
        if (CRSlotReady && [query[(__bridge id)kSecAttrAccount] hasPrefix:@"pb_remote_request_slot."] && CRSlotArrivals < 2) {
            CRSlotArrivals++; blockSlot = YES;
        }
    }
    if (blockSlot) {
        dispatch_semaphore_signal(CRSlotReady);
        dispatch_semaphore_wait(CRSlotRelease, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
    }
    @synchronized(CRLock) {
        CRAdds++;
        NSNumber *failure = CRWriteErrors[query[(__bridge id)kSecAttrAccount]];
        if (failure) { return failure.intValue; }
        if (CRAddError) { return CRAddError; }
        NSString *key = CRRecordKey(query);
        if (CRInjectDuplicate) {
            CRInjectDuplicate = NO;
            CRRecords[key] = [@"persisted-winner" dataUsingEncoding:NSUTF8StringEncoding];
            if (CRFailWinnerRead) { CRReadErrors[CRSharedKey] = @(errSecInteractionNotAllowed); }
        }
        if (CRRecords[key]) { return errSecDuplicateItem; }
        CRRecords[key] = query[(__bridge id)kSecValueData];
        CRAttributes[key] = [query mutableCopy];
        if (result && [query[(__bridge id)kSecReturnAttributes] boolValue]) {
            NSMutableDictionary *attributes = [CRReturnedAttributes(key, NO) mutableCopy];
            if (CRProbeOmitsGroup) { [attributes removeObjectForKey:(__bridge id)kSecAttrAccessGroup]; }
            *result = CFBridgingRetain(attributes);
        }
        return errSecSuccess;
    }
}

OSStatus SecItemUpdate(CFDictionaryRef rawQuery, CFDictionaryRef rawAttributes)
{
    NSDictionary *query = (__bridge NSDictionary *)rawQuery;
    NSDictionary *attributes = (__bridge NSDictionary *)rawAttributes;
    BOOL blockPriority = NO;
    @synchronized(CRLock) {
        if (CRBlockPriorityUpdate && [query[(__bridge id)kSecAttrAccount] isEqual:CRServerKey] &&
            attributes[(__bridge id)kSecAttrGeneric] && !attributes[(__bridge id)kSecValueData]) {
            CRBlockPriorityUpdate = NO; blockPriority = YES;
        }
    }
    if (blockPriority) {
        dispatch_semaphore_signal(CRPriorityReady);
        dispatch_semaphore_wait(CRPriorityRelease, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
    }
    @synchronized(CRLock) {
        CRUpdates++;
        if (!query[(__bridge id)kSecAttrAccessGroup]) { CRPrivateQueries++; }
        NSNumber *failure = CRWriteErrors[query[(__bridge id)kSecAttrAccount]];
        if (failure) { return failure.intValue; }
        NSArray *matches = CRMatchingRecords(query);
        if (!matches.count) { return errSecItemNotFound; }
        for (NSString *key in matches) {
            if (attributes[(__bridge id)kSecValueData]) { CRRecords[key] = attributes[(__bridge id)kSecValueData]; }
            if (!CRAttributes[key]) { CRAttributes[key] = [NSMutableDictionary dictionary]; }
            [CRAttributes[key] addEntriesFromDictionary:attributes];
        }
        return errSecSuccess;
    }
}

OSStatus SecItemDelete(CFDictionaryRef rawQuery)
{
    @synchronized(CRLock) {
        NSDictionary *query = (__bridge NSDictionary *)rawQuery;
        if (!query[(__bridge id)kSecAttrAccessGroup]) { CRPrivateQueries++; }
        if (CRDeleteError) { return CRDeleteError; }
        if (CRReservationDeleteError && query[(__bridge id)kSecAttrLabel]) { return CRReservationDeleteError; }
        NSArray *matches = CRMatchingRecords(query);
        for (NSString *key in matches) {
            [CRRecords removeObjectForKey:key]; [CRAttributes removeObjectForKey:key];
        }
        return matches.count ? errSecSuccess : errSecItemNotFound;
    }
}

// The manager uses real storage/generator/cache code; device collection is
// deterministic here so the regression suite can run on macOS without UIKit.
@implementation PBCrossDeviceAttributeCollector
+ (PBCrossDeviceAttributes *)collectAttributesWithConfiguration:(PBCrossConfiguration *)configuration
{
    CRCollections++;
    NSMutableDictionary *values = [@{PBCrossAttributeKeyMachine: configuration.collectsDeviceName ? @"test-device" : @"alternate-device"} mutableCopy];
    if (CRSystemUpdateFixture) { values[PBCrossAttributeKeySysFileTime] = CRSystemUpdateFixture; }
    PBCrossDeviceAttributes *attributes = [PBCrossDeviceAttributes attributesWithValues:values];
    if (CRAdvertisingFixture && CRTrackingStatus == 3 && configuration.allowsAdvertisingIdentifier) {
        NSMutableDictionary *withIDFA = [values mutableCopy];
        withIDFA[PBCrossAttributeKeyIDFAMD5] = @"authorized-idfa-md5";
        attributes = [PBCrossDeviceAttributes attributesWithValues:withIDFA
                                          advertisingIdentifier:@"6ABF0056-2C6A-4378-9E80-9143C2669683"];
    }
    if (CRCollectionReady) {
        dispatch_semaphore_signal(CRCollectionReady);
        dispatch_semaphore_wait(CRCollectionRelease, DISPATCH_TIME_FOREVER);
    }
    return attributes;
}
@end

static void CRAssert(BOOL condition, NSString *name)
{
    printf("%s %s\n", condition ? "PASS" : "FAIL", name.UTF8String);
    if (!condition) { CRFailures++; }
}

static void CRReset(void)
{
    CRRecords = [NSMutableDictionary dictionary];
    CRAttributes = [NSMutableDictionary dictionary];
    CRProbeOmitsGroup = CRBlockPriorityUpdate = NO;
    CRSlotReady = CRSlotRelease = nil; CRSlotArrivals = 0;
    CRReadErrors = [NSMutableDictionary dictionary];
    CRWriteErrors = [NSMutableDictionary dictionary];
    CRDeleteError = errSecSuccess;
    CRReservationDeleteError = errSecSuccess;
    CRAdds = CRUpdates = CRPrivateQueries = CRRaceReaders = 0;
    CRAddError = errSecSuccess;
    CRInjectDuplicate = CRFailWinnerRead = NO;
    CRRaceReady = CRRaceRelease = nil;
}

static PBCrossConfiguration *CRConfiguration(void)
{
    PBCrossConfiguration *configuration = [PBCrossConfiguration new];
    configuration.keychainService = @"cr.test.identity";
    configuration.keychainAccessGroup = @"TEAM.cr.shared";
    return configuration;
}

static NSString *CRStorageKey(NSString *account)
{
    return [NSString stringWithFormat:@"cr.test.identity/TEAM.cr.shared/%@", account];
}

static PBCrossIdentityStore *CRStore(NSString *suite)
{
    PBCrossIdentityStore *store = [[PBCrossIdentityStore alloc] initWithConfiguration:CRConfiguration()];
    [store setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
    return store;
}

static void CRVerifyReadFailures(NSString *suite)
{
    for (NSString *account in @[CRServerKey, CRSharedKey]) {
        for (NSNumber *status in @[@(errSecInteractionNotAllowed), @(errSecNotAvailable), @(errSecMissingEntitlement)]) {
            CRReset();
            NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:suite];
            [defaults removePersistentDomainForName:suite];
            NSData *oldData = [@"original-id" dataUsingEncoding:NSUTF8StringEncoding];
            CRRecords[CRStorageKey(account)] = oldData;
            CRReadErrors[account] = status;
            PBCrossIdentityStore *store = CRStore(suite);
            NSError *error = nil;
            NSString *value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
            CRAssert(value.length == 0 && error.code == status.intValue && [error.domain isEqual:NSOSStatusErrorDomain],
                     [NSString stringWithFormat:@"%@ read error %@ is preserved", account, status]);
            CRAssert(CRAdds == 0 && CRUpdates == 0 && CRPrivateQueries == 0 &&
                     [CRRecords[CRStorageKey(account)] isEqual:oldData] && ![defaults stringForKey:CRSharedKey],
                     @"read failure creates no ID, fallback, or Defaults mirror");
            [defaults setObject:@"stale-defaults-id" forKey:CRSharedKey];
            value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
            CRAssert(value.length == 0 && error && CRAdds == 0 && CRUpdates == 0 &&
                     [[defaults stringForKey:CRSharedKey] isEqual:@"stale-defaults-id"],
                     @"existing Defaults do not bypass a Keychain read error");
            [CRReadErrors removeAllObjects];
            BOOL serverIssued = NO;
            value = [store sharedIDCreatingIfNeeded:YES serverIssued:&serverIssued error:&error];
            CRAssert([value isEqual:@"original-id"] && !error && serverIssued == [account isEqual:CRServerKey],
                     @"recovery returns the original persisted ID");
        }
    }
}

static void CRVerifyCreation(NSString *suite)
{
    CRReset();
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:suite];
    [defaults removePersistentDomainForName:suite];
    PBCrossIdentityStore *store = CRStore(suite);
    NSError *error = nil;
    NSString *value = [store sharedIDCreatingIfNeeded:NO serverIssued:NULL error:&error];
    CRAssert(value.length == 0 && !error && CRAdds == 0, @"read-only missing record does not generate an ID");
    value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
    NSString *persisted = [[NSString alloc] initWithData:CRRecords[CRStorageKey(CRSharedKey)] encoding:NSUTF8StringEncoding];
    CRAssert([[NSUUID alloc] initWithUUIDString:value] && [value isEqual:persisted] && !error && CRAdds == 1 && CRUpdates == 0,
             @"first creation returns only the persisted UUID");
    CRAssert([[store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error] isEqual:value] && CRAdds == 1,
             @"subsequent reads keep the same UUID");

    CRReset();
    [defaults removePersistentDomainForName:suite];
    [defaults setObject:@"legacy-id" forKey:CRSharedKey];
    value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
    CRAssert(![value isEqual:@"legacy-id"] && value.length > 0 && !error && CRAdds == 1 && CRUpdates == 0,
             @"legacy Defaults cannot resurrect an absent Keychain identity");

    CRReset();
    [defaults removePersistentDomainForName:suite];
    CRAddError = errSecInteractionNotAllowed;
    value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
    CRAssert(value.length == 0 && error.code == CRAddError && ![defaults stringForKey:CRSharedKey] && CRRecords.count == 0,
             @"failed add returns no unsaved candidate or Defaults fallback");
    CRAddError = errSecSuccess;
    value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
    CRAssert(value.length > 0 && !error, @"creation retries after a write failure");

    for (id corrupt in @[[NSData data], [@"!invalid-id" dataUsingEncoding:NSUTF8StringEncoding],
                         [NSData dataWithBytes:(unsigned char[]){0xff} length:1], @42]) {
        CRReset();
        [defaults removePersistentDomainForName:suite];
        CRRecords[CRStorageKey(CRSharedKey)] = corrupt;
        value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
        CRAssert(value.length == 0 && error.code == errSecDecode && CRAdds == 0 && CRUpdates == 0 &&
                 [CRRecords[CRStorageKey(CRSharedKey)] isEqual:corrupt], @"corrupt record is preserved without regeneration");
    }

    for (NSNumber *failWinner in @[@NO, @YES]) {
        CRReset();
        [defaults removePersistentDomainForName:suite];
        [defaults setObject:@"losing-legacy-id" forKey:CRSharedKey];
        CRInjectDuplicate = YES;
        CRFailWinnerRead = failWinner.boolValue;
        value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
        if (failWinner.boolValue) {
            CRAssert(value.length == 0 && error.code == errSecInteractionNotAllowed && CRUpdates == 0 &&
                     [[defaults stringForKey:CRSharedKey] isEqual:@"losing-legacy-id"],
                     @"duplicate winner read failure does not expose or mirror the losing candidate");
        } else {
            CRAssert([value isEqual:@"persisted-winner"] && !error && CRUpdates == 0 &&
                     [[defaults stringForKey:[store scopedDefaultsKey:CRSharedKey]] isEqual:value], @"duplicate creation returns and mirrors the winner");
        }
    }

    CRReset();
    [defaults removePersistentDomainForName:suite];
    value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
    CRAssert(value.length > 0 && [store setServerIssuedSharedID:@"server-id"], @"explicit server identity injection succeeds");
    BOOL serverIssued = NO;
    value = [store sharedIDCreatingIfNeeded:YES serverIssued:&serverIssued error:&error];
    CRAssert([value isEqual:@"server-id"] && serverIssued && !error, @"server identity takes precedence over the random ID");
    CRAssert([store setServerIssuedSharedID:nil], @"server identity marker can be cleared");
    value = [store sharedIDCreatingIfNeeded:YES serverIssued:&serverIssued error:&error];
    CRAssert([value isEqual:@"server-id"] && !serverIssued && !error, @"clearing the server marker preserves the last shared ID");
    [store clearStoredIdentity];
    value = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
    CRAssert(value.length > 0 && ![value isEqual:@"server-id"] && !error, @"successful explicit reset creates a new persisted UUID");
}

static void CRVerifyConcurrentCreation(NSString *suiteA, NSString *suiteB)
{
    CRReset();
    [[[NSUserDefaults alloc] initWithSuiteName:suiteA] removePersistentDomainForName:suiteA];
    [[[NSUserDefaults alloc] initWithSuiteName:suiteB] removePersistentDomainForName:suiteB];
    PBCrossIdentityStore *a = CRStore(suiteA), *b = CRStore(suiteB);
    CRRaceReady = dispatch_semaphore_create(0);
    CRRaceRelease = dispatch_semaphore_create(0);
    dispatch_group_t group = dispatch_group_create();
    __block NSString *idA, *idB;
    __block NSError *errorA, *errorB;
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        idA = [a sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&errorA];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        idB = [b sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&errorB];
    });
    BOOL bothReady = dispatch_semaphore_wait(CRRaceReady, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC)) == 0;
    bothReady &= dispatch_semaphore_wait(CRRaceReady, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC)) == 0;
    dispatch_semaphore_signal(CRRaceRelease);
    dispatch_semaphore_signal(CRRaceRelease);
    BOOL finished = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC)) == 0;
    CRAssert(bothReady && finished, @"two independent stores both observe a missing record before creation");
    if (!finished) { exit(1); }
    NSString *persisted = [[NSString alloc] initWithData:CRRecords[CRStorageKey(CRSharedKey)] encoding:NSUTF8StringEncoding];
    CRAssert(idA.length > 0 && [idA isEqual:idB] && [idA isEqual:persisted] && !errorA && !errorB &&
             CRAdds == 2 && CRUpdates == 0, @"concurrent creators return the same persisted ID without overwrites");
    NSUserDefaults *defaultsA = [[NSUserDefaults alloc] initWithSuiteName:suiteA];
    NSUserDefaults *defaultsB = [[NSUserDefaults alloc] initWithSuiteName:suiteB];
    CRAssert([[defaultsA stringForKey:[a scopedDefaultsKey:CRSharedKey]] isEqual:persisted] && [[defaultsB stringForKey:[b scopedDefaultsKey:CRSharedKey]] isEqual:persisted],
             @"both apps mirror only the persisted winner");
}

static void CRVerifyAppGroupConfiguration(NSString *suite)
{
    CRReset();
    PBCrossConfiguration *configuration = [PBCrossConfiguration new];
    NSError *error = nil;
    CRAssert([configuration validateWithError:&error], @"default app-local configuration remains valid");
    configuration.appGroupIdentifier = @"group.cr.shared";
    CRAssert(![configuration validateWithError:&error] &&
             error.code == PBCrossIdentifierErrorInvalidConfiguration &&
             [error.domain isEqual:PBCrossIdentifierErrorDomain], @"App Group without shared Keychain is rejected");
    for (NSString *emptyGroup in @[@"", @" \n\t"]) {
        configuration.keychainAccessGroup = emptyGroup;
        error = nil;
        CRAssert(![configuration validateWithError:&error] && error.code == PBCrossIdentifierErrorInvalidConfiguration,
                 @"empty or whitespace Keychain group cannot enable App Group sharing");
    }
    configuration.keychainAccessGroup = @"TEAM.cr.shared";
    CRAssert([configuration validateWithError:NULL], @"shared Keychain with App Group remains valid");
    configuration.appGroupIdentifier = nil;
    CRAssert([configuration validateWithError:NULL], @"shared Keychain without App Group remains valid");

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:suite];
    [defaults removePersistentDomainForName:suite];
    NSString *groupSuite = [suite stringByAppendingString:@".group"];
    NSUserDefaults *groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:groupSuite];
    [groupDefaults setObject:@"existing-group-id" forKey:CRSharedKey];
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRAssert([manager configureWithBlock:^(PBCrossConfiguration *config) {
        config.keychainService = CRConfiguration().keychainService;
        config.keychainAccessGroup = CRConfiguration().keychainAccessGroup;
        config.appGroupIdentifier = nil;
    } error:NULL], @"valid configuration can be installed before a rejected update");
    PBCrossIdentityStore *originalStore = CRStore(suite);
    [manager setValue:originalStore forKey:@"storeStorage"];
    PBCrossIdentity *originalIdentity = manager.identitySynchronously;
    NSDictionary *originalRecords = [CRRecords copy];
    NSNumber *originalGeneration = [manager valueForKey:@"configurationGeneration"];
    NSUInteger originalAdds = CRAdds, originalUpdates = CRUpdates;

    // Simultaneous host configuration attempts are rejected before either can
    // install its own private Keychain store or mirror an ID into App Group.
    dispatch_group_t group = dispatch_group_create();
    __block BOOL acceptedA = YES, acceptedB = YES;
    __block NSError *errorA, *errorB;
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        acceptedA = [manager configureWithBlock:^(PBCrossConfiguration *config) {
            config.keychainAccessGroup = nil;
            config.keychainService = @"hostA.private";
            config.appGroupIdentifier = groupSuite;
        } error:&errorA];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        acceptedB = [manager configureWithBlock:^(PBCrossConfiguration *config) {
            config.keychainAccessGroup = nil;
            config.keychainService = @"hostB.private";
            config.appGroupIdentifier = groupSuite;
        } error:&errorB];
    });
    if (dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC)) != 0) {
        fprintf(stderr, "FAIL App Group configuration checks timed out\n");
        exit(1);
    }
    CRAssert(!acceptedA && !acceptedB && errorA.code == PBCrossIdentifierErrorInvalidConfiguration &&
             errorB.code == PBCrossIdentifierErrorInvalidConfiguration,
             @"both App Group-only hosts receive configuration errors instead of private IDs");
    CRAssert([manager.configuration.keychainAccessGroup isEqual:CRConfiguration().keychainAccessGroup] &&
             [manager.configuration.keychainService isEqual:CRConfiguration().keychainService] &&
             manager.configuration.appGroupIdentifier == nil &&
             [originalGeneration isEqual:[manager valueForKey:@"configurationGeneration"]],
             @"rejected concurrent updates preserve the original configuration and generation");
    CRAssert([manager valueForKey:@"storeStorage"] == originalStore && manager.cachedIdentity == originalIdentity &&
             manager.identitySynchronously == originalIdentity && [originalRecords isEqual:CRRecords] &&
             CRAdds == originalAdds && CRUpdates == originalUpdates && CRPrivateQueries == 0 &&
             [[groupDefaults stringForKey:CRSharedKey] isEqual:@"existing-group-id"],
             @"rejected App Group-only updates leave storage, cache, and existing group identity untouched");
    [groupDefaults removePersistentDomainForName:groupSuite];
}


static void CRPumpUntil(BOOL (^done)(void))
{
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:5];
    while (!done() && deadline.timeIntervalSinceNow > 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    }
    CRAssert(done(), @"expected manager callback is delivered");
}

static void CRPrepareManager(NSString *suite)
{
    CRReset();
    [[[NSUserDefaults alloc] initWithSuiteName:suite] removePersistentDomainForName:suite];
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    [manager configureWithBlock:^(PBCrossConfiguration *configuration) {
        configuration.keychainService = CRConfiguration().keychainService;
        configuration.keychainAccessGroup = CRConfiguration().keychainAccessGroup;
        configuration.appGroupIdentifier = nil;
        configuration.collectsDeviceName = YES;
        configuration.allowsAdvertisingIdentifier = NO;
        configuration.remoteConfiguration.enabled = NO;
        configuration.automaticallyRefreshesRemoteIdentity = NO;
    } error:NULL];
    [manager setValue:CRStore(suite) forKey:@"storeStorage"];
}

static void CRVerifyAdvertisingRevocation(NSString *suite)
{
    CRPrepareManager(suite);
    CRTrackingStatus = 3; CRAdvertisingFixture = YES;
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    [manager configureWithBlock:^(PBCrossConfiguration *configuration) {
        configuration.allowsAdvertisingIdentifier = YES;
        configuration.emitsRawAdvertisingIdentifier = YES;
    } error:NULL];
    [manager setValue:CRStore(suite) forKey:@"storeStorage"];
    PBCrossIdentity *authorized = manager.identitySynchronously;
    PBCrossAdRequestContext *context = [[PBCrossAdRequestContext alloc] init];
    context.advertisingIdentifier = authorized.attributes.advertisingIdentifier;
    PBCrossAdRequestAdapter *existingAdapter = [manager adRequestAdapterWithContext:context];
    CRAssert(existingAdapter.deviceDictionary[@"idfa"] != nil && existingAdapter.deviceDictionary[@"idfa_md5"] != nil,
             @"authorized cached identity exports IDFA when enabled");
    NSUInteger collections = CRCollections;
    for (NSNumber *status in @[@2, @1, @0]) {
        CRTrackingStatus = status.integerValue;
        CRAssert(existingAdapter.deviceDictionary[@"idfa"] == nil && existingAdapter.deviceDictionary[@"idfa_md5"] == nil &&
                 existingAdapter.extensionObject[@"pb_cross_app"][@"attributes"][@"idfa_md5"] == nil,
                 @"existing adapter blocks raw, hashed, context IDFA and ext after authorization changes");
    }
    CRTrackingStatus = 2;
    CRAssert(manager.cachedIdentity.attributes.advertisingIdentifier == nil &&
             manager.identitySynchronously.attributes.advertisingIdentifierMD5 == nil,
             @"cached and synchronous identities remove revoked advertising fields");
    __block NSUInteger callbacks = 0;
    [manager loadIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
        callbacks++;
        CRAssert(NSThread.isMainThread && !error && identity.attributes.advertisingIdentifier == nil &&
                 identity.attributes.advertisingIdentifierMD5 == nil && [identity.sharedID isEqual:authorized.sharedID] &&
                 [identity.currentIdentifier isEqual:authorized.currentIdentifier],
                 @"normal cached load removes IDFA while preserving shared and default fingerprint IDs");
    }];
    CRPumpUntil(^BOOL { return callbacks == 1; });
    CRAssert(CRCollections == collections, @"authorization check preserves non-advertising cache without recollection");
    CRTrackingStatus = 3;
    [manager refreshIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
        callbacks++;
        CRAssert(identity.attributes.advertisingIdentifierMD5 != nil, @"fresh authorized collection restores advertising fields");
    }];
    CRPumpUntil(^BOOL { return callbacks == 2; });

    // Queue the callback while authorized, then revoke before main-thread delivery.
    [manager loadIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
        callbacks++;
        CRAssert(identity.attributes.advertisingIdentifierMD5 == nil, @"authorization is rechecked at callback delivery");
    }];
    dispatch_sync([manager valueForKey:@"workQueue"], ^{});
    CRTrackingStatus = 2;
    CRPumpUntil(^BOOL { return callbacks == 3; });
    CRAdvertisingFixture = NO; CRTrackingStatus = 3;
}

static void CRVerifyConfigurationRace(NSString *suite, BOOL duringCollection)
{
    CRPrepareManager(suite);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRRecords[CRStorageKey(CRSharedKey)] = [@"old-scope-id" dataUsingEncoding:NSUTF8StringEncoding];
    CRCollections = 0;
    CRCollectionReady = duringCollection ? dispatch_semaphore_create(0) : nil;
    CRCollectionRelease = duringCollection ? dispatch_semaphore_create(0) : nil;
    __block NSUInteger callbacks = 0;
    [manager refreshIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
        callbacks++;
        CRAssert(NSThread.isMainThread && identity == nil &&
                 [error.domain isEqual:PBCrossIdentifierErrorDomain] && error.code == PBCrossIdentifierErrorOperationCancelled,
                 @"old-generation load returns cancellation without exposing obsolete identity");
    }];
    if (duringCollection) {
        CRAssert(dispatch_semaphore_wait(CRCollectionReady, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0,
                 @"old load captures its configuration before collection finishes");
    } else {
        dispatch_sync([manager valueForKey:@"workQueue"], ^{});
    }
    [manager configureWithBlock:^(PBCrossConfiguration *configuration) {
        configuration.keychainService = @"cr.new.scope";
        configuration.keychainAccessGroup = @"TEAM.cr.other";
        configuration.salt = @"new-salt";
        configuration.collectsDeviceName = NO;
    } error:NULL];
    PBCrossIdentityStore *newStore = [[PBCrossIdentityStore alloc] initWithConfiguration:manager.configuration];
    [newStore setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
    [manager setValue:newStore forKey:@"storeStorage"];
    CRRecords[@"cr.new.scope/TEAM.cr.other/pb_shared_id"] = [@"new-scope-id" dataUsingEncoding:NSUTF8StringEncoding];
    if (duringCollection) {
        dispatch_semaphore_signal(CRCollectionRelease);
        dispatch_sync([manager valueForKey:@"workQueue"], ^{});
        CRCollectionReady = CRCollectionRelease = nil;
    }
    CRAssert(manager.cachedIdentity == nil, @"obsolete work cannot repopulate the new configuration cache");
    CRPumpUntil(^BOOL { return callbacks == 1; });
    PBCrossIdentity *fresh = manager.identitySynchronously;
    NSString *expected = [PBCrossIdentityGenerator fingerprintIdentifiersWithAttributes:
        [PBCrossDeviceAttributes attributesWithValues:@{PBCrossAttributeKeyMachine:@"alternate-device"}]
        configuration:manager.configuration].firstObject.value;
    CRAssert([fresh.sharedID isEqual:@"new-scope-id"] && [fresh.currentIdentifier isEqual:expected] &&
             [manager.sharedID isEqual:fresh.sharedID] && manager.cachedIdentity == fresh,
             @"new load uses matching attributes, salt, access group, service and cache");
}


static dispatch_semaphore_t CRStoreReady, CRStoreRelease;
static OSStatus CRBlockedReadStatus;
@interface CRBlockedIdentityStore : PBCrossIdentityStore
@end
@implementation CRBlockedIdentityStore
- (NSString *)sharedIDCreatingIfNeeded:(BOOL)create serverIssued:(BOOL *)serverIssued error:(NSError **)error
{
    dispatch_semaphore_signal(CRStoreReady);
    dispatch_semaphore_wait(CRStoreRelease, DISPATCH_TIME_FOREVER);
    if (CRBlockedReadStatus) {
        if (error) { *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:CRBlockedReadStatus userInfo:nil]; }
        return @"";
    }
    return [super sharedIDCreatingIfNeeded:create serverIssued:serverIssued error:error];
}
@end

static void CRVerifyStaleStoreCannotChangeCache(NSString *suite, BOOL failing)
{
    CRPrepareManager(suite);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRBlockedIdentityStore *blocked = [[CRBlockedIdentityStore alloc] initWithConfiguration:manager.configuration];
    [blocked setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
    [manager setValue:blocked forKey:@"storeStorage"];
    CRStoreReady = dispatch_semaphore_create(0); CRStoreRelease = dispatch_semaphore_create(0);
    CRBlockedReadStatus = failing ? errSecInteractionNotAllowed : 0;
    __block NSUInteger callbacks = 0;
    [manager refreshIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
        callbacks++;
        CRAssert(identity == nil && error.code == PBCrossIdentifierErrorOperationCancelled,
                 @"stale store success or failure delivers cancellation");
    }];
    CRAssert(dispatch_semaphore_wait(CRStoreReady, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0,
             @"old load is paused inside its captured store");
    dispatch_semaphore_t mutationStarted = dispatch_semaphore_create(0), mutationDone = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_signal(mutationStarted);
        [manager configureWithBlock:^(PBCrossConfiguration *configuration) {
            configuration.keychainService = @"cr.current.scope";
        } error:NULL];
        dispatch_semaphore_signal(mutationDone);
    });
    dispatch_semaphore_wait(mutationStarted, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));
    CRAssert(dispatch_semaphore_wait(mutationDone, dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC)) != 0,
             @"configuration commit waits for an already-started storage operation");
    dispatch_semaphore_signal(CRStoreRelease);
    BOOL mutated = dispatch_semaphore_wait(mutationDone, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC)) == 0;
    CRAssert(mutated, @"configuration commits after storage returns");
    if (!mutated) { exit(1); }
    dispatch_sync([manager valueForKey:@"workQueue"], ^{});
    PBCrossIdentityStore *currentStore = [[PBCrossIdentityStore alloc] initWithConfiguration:manager.configuration];
    [currentStore setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
    [manager setValue:currentStore forKey:@"storeStorage"];
    CRRecords[@"cr.current.scope/TEAM.cr.shared/pb_shared_id"] = [@"current-scope-id" dataUsingEncoding:NSUTF8StringEncoding];
    PBCrossIdentity *current = manager.identitySynchronously;
    CRAssert(manager.cachedIdentity == current && [manager.identitySynchronously.sharedID isEqual:@"current-scope-id"],
             @"stale store success cannot overwrite, and stale failure cannot erase, the new cache");
    CRPumpUntil(^BOOL { return callbacks == 1; });
    CRBlockedReadStatus = 0;
}


static void CRVerifySynchronousConfigurationRetry(NSString *suite)
{
    CRPrepareManager(suite);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRCollectionReady = dispatch_semaphore_create(0); CRCollectionRelease = dispatch_semaphore_create(0);
    dispatch_semaphore_t finished = dispatch_semaphore_create(0);
    __block PBCrossIdentity *returned = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        returned = manager.identitySynchronously;
        dispatch_semaphore_signal(finished);
    });
    CRAssert(dispatch_semaphore_wait(CRCollectionReady, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0,
             @"synchronous load captures the old context before configuration changes");
    [manager configureWithBlock:^(PBCrossConfiguration *configuration) {
        configuration.keychainService = @"cr.sync.scope";
    } error:NULL];
    PBCrossIdentityStore *currentStore = [[PBCrossIdentityStore alloc] initWithConfiguration:manager.configuration];
    [currentStore setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
    [manager setValue:currentStore forKey:@"storeStorage"];
    CRRecords[@"cr.sync.scope/TEAM.cr.shared/pb_shared_id"] = [@"sync-current-id" dataUsingEncoding:NSUTF8StringEncoding];
    // The retry must not hit the old collection barrier a second time.
    dispatch_semaphore_t release = CRCollectionRelease;
    CRCollectionReady = nil;
    dispatch_semaphore_signal(release);
    CRAssert(dispatch_semaphore_wait(finished, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC)) == 0 &&
             [returned.sharedID isEqual:@"sync-current-id"] && manager.cachedIdentity == returned,
             @"synchronous load retries against the latest configuration without returning the obsolete identity");
    CRCollectionRelease = nil;
}

static void CRVerifyManagerRecovery(NSString *suite)
{
    CRReset();
    [[[NSUserDefaults alloc] initWithSuiteName:suite] removePersistentDomainForName:suite];
    CRRecords[CRStorageKey(CRSharedKey)] = [@"original-id" dataUsingEncoding:NSUTF8StringEncoding];
    CRReadErrors[CRSharedKey] = @(errSecInteractionNotAllowed);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    [manager configureWithBlock:^(PBCrossConfiguration *configuration) {
        configuration.keychainService = CRConfiguration().keychainService;
        configuration.keychainAccessGroup = CRConfiguration().keychainAccessGroup;
        configuration.remoteConfiguration.enabled = NO;
    } error:NULL];
    [manager setValue:CRStore(suite) forKey:@"storeStorage"];
    [manager loadIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
        CRAssert(NSThread.isMainThread && identity && identity.sharedID.length == 0 && error.code == errSecInteractionNotAllowed,
                 @"manager reports storage error to the page on the main thread");
        CRAssert(manager.cachedIdentity == nil && manager.sharedID.length == 0,
                 @"manager does not cache an incomplete identity or expose a substitute shared ID");
        [manager resolveRemoteIdentityWithCompletion:^(PBCrossIdentity *remoteIdentity, NSError *remoteError) {
            CRAssert(remoteIdentity.sharedID.length == 0 && remoteError.code == errSecInteractionNotAllowed,
                     @"explicit remote resolution also preserves the storage error");
            [CRReadErrors removeAllObjects];
            [manager loadIdentityWithCompletion:^(PBCrossIdentity *recovered, NSError *recoveryError) {
                CRAssert([recovered.sharedID isEqual:@"original-id"] && !recoveryError && manager.cachedIdentity == recovered,
                         @"normal load retries after recovery without waiting for cache expiry");
                for (NSString *cleanupSuite in @[suite, [suite stringByAppendingString:@".peer"]]) {
                    [[[NSUserDefaults alloc] initWithSuiteName:cleanupSuite] removePersistentDomainForName:cleanupSuite];
                }
                printf("\n%d storage regression failure(s).\n", CRFailures);
                exit(CRFailures == 0 ? 0 : 1);
            }];
        }];
    }];
}


static void CRVerifyMirrorsAndNamespace(NSString *suite)
{
    CRPrepareManager(suite);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    PBCrossIdentityStore *a = [manager valueForKey:@"storeStorage"];
    NSString *peerSuite = [suite stringByAppendingString:@".peer"];
    NSUserDefaults *peerDefaults = [[NSUserDefaults alloc] initWithSuiteName:peerSuite];
    [peerDefaults removePersistentDomainForName:peerSuite];
    PBCrossIdentityStore *peer = CRStore(peerSuite);
    NSString *old = [a sharedIDCreatingIfNeeded:YES serverIssued:NULL error:NULL];
    [peer sharedIDCreatingIfNeeded:YES serverIssued:NULL error:NULL];
    CRAssert([[peerDefaults stringForKey:[peer scopedDefaultsKey:CRSharedKey]] isEqual:old], @"peer App holds its private old mirror");
    NSError *error = nil;
    CRAssert([manager clearStoredIdentityWithError:&error] && !error, @"shared identity clear succeeds");
    NSString *next = [peer sharedIDCreatingIfNeeded:YES serverIssued:NULL error:NULL];
    CRAssert(![next isEqual:old] && [manager.sharedID isEqual:next], @"peer mirror cannot restore a cleared shared identity");
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:suite];
    for (NSNumber *changeGroup in @[@NO, @YES]) {
        PBCrossConfiguration *config = CRConfiguration();
        if (changeGroup.boolValue) { config.keychainAccessGroup = @"TEAM.independent"; }
        else { config.keychainService = @"independent.service"; }
        PBCrossIdentityStore *other = [[PBCrossIdentityStore alloc] initWithConfiguration:config];
        [other setValue:defaults forKey:@"standardDefaults"];
        NSString *separate = [other sharedIDCreatingIfNeeded:YES serverIssued:NULL error:NULL];
        CRAssert(separate.length > 0 && ![separate isEqual:next] &&
            [[defaults stringForKey:[a scopedDefaultsKey:CRSharedKey]] isEqual:next] &&
            [[defaults stringForKey:[other scopedDefaultsKey:CRSharedKey]] isEqual:separate],
            @"service and access group each isolate their persistent IDs and mirrors");
    }
}

static void CRVerifyMutationFailures(NSString *suite)
{
    CRPrepareManager(suite);
    PBCrossAppUniqueDeviceIdentifierManager *m = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    NSString *old = m.identitySynchronously.sharedID;
    CRWriteErrors[CRServerKey] = @(errSecInteractionNotAllowed);
    CRAssert(![m setServerIssuedSharedID:@"server-new"] && [m.sharedID isEqual:old] &&
             [m.cachedIdentity.sharedID isEqual:old], @"failed authoritative write changes neither direct nor cached identity");
    [CRWriteErrors removeAllObjects];
    CRWriteErrors[CRSharedKey] = @(errSecInteractionNotAllowed);
    CRAssert([m setServerIssuedSharedID:@"server-new"] && [m.identitySynchronously.sharedID isEqual:@"server-new"] &&
             [m.sharedID isEqual:@"server-new"], @"server injection has one authoritative write, so a second-key failure cannot split identity");
    CRAssert([m setServerIssuedSharedID:nil] && [m.sharedID isEqual:@"server-new"],
             @"priority removal keeps the value without writing the secondary shared key");
    [CRWriteErrors removeAllObjects];
    CRWriteErrors[CRServerKey] = @(errSecInteractionNotAllowed);
    CRAssert(![m setServerIssuedSharedID:nil] && [m.sharedID isEqual:@"server-new"],
             @"priority metadata update failure preserves identity and reports failure");
    [CRWriteErrors removeAllObjects];
    CRDeleteError = errSecInteractionNotAllowed;
    NSError *error = nil;
    CRAssert(![m clearStoredIdentityWithError:&error] && error.code == errSecInteractionNotAllowed &&
             [m.sharedID isEqual:@"server-new"] && !m.cachedIdentity,
             @"clear propagates Keychain delete error and invalidates cached identity");
    CRDeleteError = errSecSuccess;
    CRAssert([m clearStoredIdentityWithError:&error] && !error && ![m.sharedID isEqual:@"server-new"],
             @"clear retries successfully after Keychain recovery");
}

static void CRVerifyLateRemote(NSString *suite, BOOL reconfigure)
{
    CRPrepareManager(suite);
    PBCrossAppUniqueDeviceIdentifierManager *m = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    PBCrossIdentityStore *store = [m valueForKey:@"storeStorage"];
    PBCrossRemoteResolver *resolver = [[PBCrossRemoteResolver alloc] initWithConfiguration:m.configuration store:store];
    [m setValue:resolver forKey:@"remoteResolverStorage"];
    [store setRemoteCache:@{@"identifiers": @[@{@"id": @"before-clear", @"version": @"1"}]}];
    if (reconfigure) {
        [m configureWithBlock:^(PBCrossConfiguration *c) { c.salt = @"updated-salt"; } error:NULL];
        [store setRemoteCache:nil];
    } else { [m clearStoredIdentityWithError:NULL]; }
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"code": @0, @"data": @[@{@"id": @"late-old-response", @"version": @"1"}]} options:0 error:NULL];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://example.invalid"] statusCode:200 HTTPVersion:nil headerFields:nil];
    __block BOOL done = NO;
    [resolver handleResponseData:data response:response networkError:nil completion:^(NSArray *ids, NSDate *date, NSError *error) {
        CRAssert(ids == nil && error.code == PBCrossIdentifierErrorOperationCancelled, @"invalidated response delivers cancellation");
        done = YES;
    }];
    CRPumpUntil(^BOOL { return done; });
    CRAssert(store.remoteCache == nil, @"late response after clear or reconfiguration cannot repopulate persistent cache");
}

@interface CRPostReadStore : PBCrossIdentityStore
@end
@implementation CRPostReadStore
- (NSString *)updateSystemUpdateTimeHistoryWithCurrentValue:(NSString *)value
{
    dispatch_semaphore_signal(CRStoreReady);
    dispatch_semaphore_wait(CRStoreRelease, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
    return [super updateSystemUpdateTimeHistoryWithCurrentValue:value];
}
@end

static void CRVerifyServerInjectionRace(NSString *suite, BOOL afterBuild)
{
    CRPrepareManager(suite);
    PBCrossAppUniqueDeviceIdentifierManager *m = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRRecords[CRStorageKey(CRSharedKey)] = [@"before-server" dataUsingEncoding:NSUTF8StringEncoding];
    if (!afterBuild) {
        CRPostReadStore *store = [[CRPostReadStore alloc] initWithConfiguration:m.configuration];
        [store setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
        [m setValue:store forKey:@"storeStorage"];
        CRStoreReady = dispatch_semaphore_create(0); CRStoreRelease = dispatch_semaphore_create(0);
    }
    __block BOOL done = NO;
    [m refreshIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
        CRAssert(identity == nil && error.code == PBCrossIdentifierErrorOperationCancelled,
                 @"server injection cancels old load even while its main-thread callback is queued");
        done = YES;
    }];
    if (afterBuild) { dispatch_sync([m valueForKey:@"workQueue"], ^{}); }
    else { CRAssert(dispatch_semaphore_wait(CRStoreReady, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0, @"load paused after reading old shared ID"); }
    if (!afterBuild) {
        dispatch_semaphore_t injectionStarted = dispatch_semaphore_create(0), injectionDone = dispatch_semaphore_create(0);
        __block BOOL injected = NO;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_signal(injectionStarted);
            injected = [m setServerIssuedSharedID:@"server-new"];
            dispatch_semaphore_signal(injectionDone);
        });
        dispatch_semaphore_wait(injectionStarted, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));
        CRAssert(dispatch_semaphore_wait(injectionDone, dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC)) != 0,
                 @"server injection waits for the identity storage critical section");
        dispatch_semaphore_signal(CRStoreRelease);
        CRAssert(dispatch_semaphore_wait(injectionDone, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC)) == 0 && injected,
                 @"server injection succeeds after old storage completes");
    } else {
        CRAssert([m setServerIssuedSharedID:@"server-new"], @"server injection succeeds while old callback is pending");
    }
    CRPumpUntil(^BOOL { return done; });
    // Replace only the test barrier, preserving the same actual storage namespace.
    [m setValue:CRStore(suite) forKey:@"storeStorage"];
    CRAssert([m.identitySynchronously.sharedID isEqual:@"server-new"] && [m.cachedIdentity.sharedID isEqual:m.sharedID],
             @"old load cannot restore pre-injection identity to cache");
}

static void CRVerifyDefaultGroupIsolation(NSString *suite)
{
    CRReset();
    NSString *sharedRecord = CRStorageKey(CRSharedKey);
    NSString *sharedServerRecord = CRStorageKey(CRServerKey);
    NSString *privateRecord = [NSString stringWithFormat:@"cr.test.identity/%@/%@", CRDefaultGroup, CRSharedKey];
    CRRecords[sharedRecord] = [@"shared-scope-id" dataUsingEncoding:NSUTF8StringEncoding];
    CRRecords[sharedServerRecord] = [@"shared-server-id" dataUsingEncoding:NSUTF8StringEncoding];
    PBCrossConfiguration *configuration = CRConfiguration(); configuration.keychainAccessGroup = nil;
    PBCrossIdentityStore *store = [[PBCrossIdentityStore alloc] initWithConfiguration:configuration];
    [store setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
    NSError *error = nil;
    NSString *own = [store sharedIDCreatingIfNeeded:YES serverIssued:NULL error:&error];
    CRAssert(own.length && ![own isEqual:@"shared-scope-id"] && ![own isEqual:@"shared-server-id"] && CRRecords[privateRecord] && !error,
             @"default group discovery creates an independent ID without reading accessible shared groups");
    CRAssert([store setServerIssuedSharedID:@"default-server"] &&
             [[store sharedIDCreatingIfNeeded:NO serverIssued:NULL error:NULL] isEqual:@"default-server"] &&
             [[[NSString alloc] initWithData:CRRecords[sharedRecord] encoding:NSUTF8StringEncoding] isEqual:@"shared-scope-id"] &&
             [[[NSString alloc] initWithData:CRRecords[sharedServerRecord] encoding:NSUTF8StringEncoding] isEqual:@"shared-server-id"],
             @"default-group injection never updates an accessible shared-group record");
    CRAssert([store clearStoredIdentityWithError:&error] && !error && !CRRecords[privateRecord] && CRRecords[sharedRecord] && CRRecords[sharedServerRecord] &&
             CRPrivateQueries == 0, @"default-group clear leaves shared records intact and issues no unscoped queries");

    // Fail closed before any identity read/update/delete when group resolution fails.
    for (NSNumber *failureKind in @[@0, @1, @2]) {
        CRReset(); CRRecords[sharedRecord] = [@"keep-shared" dataUsingEncoding:NSUTF8StringEncoding];
        PBCrossIdentityStore *unresolved = [[PBCrossIdentityStore alloc] initWithConfiguration:configuration];
        [unresolved setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
        if (failureKind.integerValue == 2) { CRDeleteError = errSecInteractionNotAllowed; }
        else if (failureKind.integerValue == 1) { CRProbeOmitsGroup = YES; }
        else { CRAddError = errSecInteractionNotAllowed; }
        error = nil;
        CRAssert(![unresolved clearStoredIdentityWithError:&error] && error && CRRecords[sharedRecord] && CRPrivateQueries == 0,
                 @"failed default-group discovery cannot broaden a clear to other groups");
    }
}

static void CRVerifyConcurrentPriorityRemoval(NSString *suite)
{
    CRReset();
    PBCrossIdentityStore *a = CRStore(suite), *b = CRStore([suite stringByAppendingString:@".peer"]);
    [a setServerIssuedSharedID:@"server-A"];
    CRBlockPriorityUpdate = YES;
    CRPriorityReady = dispatch_semaphore_create(0); CRPriorityRelease = dispatch_semaphore_create(0);
    dispatch_semaphore_t done = dispatch_semaphore_create(0);
    __block BOOL removed = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        removed = [a setServerIssuedSharedID:nil]; dispatch_semaphore_signal(done);
    });
    BOOL ready = dispatch_semaphore_wait(CRPriorityReady, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0;
    BOOL injected = [b setServerIssuedSharedID:@"server-B"];
    NSString *observed = [b sharedIDCreatingIfNeeded:NO serverIssued:NULL error:NULL];
    dispatch_semaphore_signal(CRPriorityRelease);
    BOOL finished = dispatch_semaphore_wait(done, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC)) == 0;
    BOOL server = YES;
    NSString *final = [b sharedIDCreatingIfNeeded:NO serverIssued:&server error:NULL];
    CRAssert(ready && finished && removed && injected && [observed isEqual:@"server-B"] &&
             [final isEqual:@"server-B"] && !server, @"priority removal after a peer injection preserves the newest ID atomically");
    CRAssert([a setServerIssuedSharedID:@"server-C"] &&
             [[b sharedIDCreatingIfNeeded:NO serverIssued:&server error:NULL] isEqual:@"server-C"] && server,
             @"a later injection restores server priority and keeps its new ID");
    CRReadErrors[CRServerKey] = @(errSecInteractionNotAllowed);
    CRAssert(![a setServerIssuedSharedID:nil], @"priority removal preserves read errors before metadata mutation");
    [CRReadErrors removeAllObjects];
    CRRecords[CRStorageKey(CRServerKey)] = [@"!corrupt" dataUsingEncoding:NSUTF8StringEncoding];
    CRAssert(![a setServerIssuedSharedID:nil], @"priority removal does not turn a corrupt record into success");
}

static void CRVerifySharedCacheAuthority(NSString *suite)
{
    CRReset();
    NSString *peerSuite = [suite stringByAppendingString:@".peer"], *groupSuite = [suite stringByAppendingString:@".group"];
    NSUserDefaults *group = [[NSUserDefaults alloc] initWithSuiteName:groupSuite];
    [group removePersistentDomainForName:groupSuite];
    PBCrossIdentityStore *a = CRStore(suite), *b = CRStore(peerSuite);
    [a setValue:group forKey:@"groupDefaults"]; [b setValue:group forKey:@"groupDefaults"];
    NSDictionary *cache = @{@"resolved_at": @(NSDate.date.timeIntervalSince1970),
                            @"identifiers": @[@{@"id": @"old-remote", @"version": @"1"}]};
    [b setRemoteCache:cache];
    NSUserDefaults *private = [b valueForKey:@"standardDefaults"];
    // Model a private copy left by the previous release.
    for (NSString *key in group.dictionaryRepresentation) {
        if ([key containsString:@"pb_remote_cache."]) { [private setObject:[group objectForKey:key] forKey:key]; }
    }
    CRAssert(a.remoteCache != nil, @"peer reads the shared remote cache before clear");
    [a clearStoredIdentityWithError:NULL];
    PBCrossIdentityStore *restarted = CRStore(peerSuite);
    [restarted setValue:[[NSUserDefaults alloc] initWithSuiteName:groupSuite] forKey:@"groupDefaults"];
    CRAssert(!a.remoteCache && !b.remoteCache && !restarted.remoteCache,
             @"shared clear is authoritative for peers and restarted stores despite legacy private cache");
    [a setRemoteCache:cache];
    CRAssert(b.remoteCache != nil, @"a new shared cache is visible after clear");
    [group removePersistentDomainForName:groupSuite];
}

static void CRVerifyAtomicRequestQuota(NSString *suite)
{
    CRReset();
    PBCrossIdentityStore *a = CRStore(suite), *b = CRStore([suite stringByAppendingString:@".peer"]);
    CRAssert(![a registerRemoteRequestIfAllowed:0] && CRAdds == 0, @"zero request limit reserves nothing");
    CRSlotReady = dispatch_semaphore_create(0); CRSlotRelease = dispatch_semaphore_create(0);
    dispatch_group_t done = dispatch_group_create();
    __block BOOL allowedA = NO, allowedB = NO;
    dispatch_group_async(done, dispatch_get_global_queue(0, 0), ^{ allowedA = [a registerRemoteRequestIfAllowed:1]; });
    dispatch_group_async(done, dispatch_get_global_queue(0, 0), ^{ allowedB = [b registerRemoteRequestIfAllowed:1]; });
    BOOL ready = dispatch_semaphore_wait(CRSlotReady, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0;
    ready &= dispatch_semaphore_wait(CRSlotReady, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0;
    dispatch_semaphore_signal(CRSlotRelease); dispatch_semaphore_signal(CRSlotRelease);
    BOOL finished = dispatch_group_wait(done, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC)) == 0;
    CRAssert(ready && finished && (allowedA != allowedB), @"two independent stores contend for limit 1 and exactly one succeeds");
    CRSlotReady = CRSlotRelease = nil;
    PBCrossIdentityStore *restarted = CRStore(suite);
    CRAssert(![restarted registerRemoteRequestIfAllowed:1], @"request reservations survive store restart");
    NSError *error = nil;
    [a clearStoredIdentityWithError:&error];
    CRAssert(!error && [b registerRemoteRequestIfAllowed:1] && ![a registerRemoteRequestIfAllowed:1],
             @"clear releases shared quota without private count resurrection");
    PBCrossConfiguration *otherConfig = CRConfiguration(); otherConfig.keychainAccessGroup = @"TEAM.quota.other";
    PBCrossIdentityStore *other = [[PBCrossIdentityStore alloc] initWithConfiguration:otherConfig];
    CRAssert([other registerRemoteRequestIfAllowed:1], @"request quota is isolated by Keychain namespace");
    CRAddError = errSecInteractionNotAllowed;
    CRAssert(![a registerRemoteRequestIfAllowed:2 error:&error] && error.code == errSecInteractionNotAllowed,
             @"request quota storage failure fails closed with the underlying error");
    CRAddError = errSecSuccess;

    CRReservationDeleteError = errSecInteractionNotAllowed;
    CRAssert(![a clearStoredIdentityWithError:&error] && error.code == errSecInteractionNotAllowed &&
             ![b registerRemoteRequestIfAllowed:1], @"quota deletion failure is reported and does not silently release reservations");
    CRReservationDeleteError = errSecSuccess;
    CRAssert([a clearStoredIdentityWithError:&error] && !error && [b registerRemoteRequestIfAllowed:1],
             @"quota clear can be retried after storage recovery");

    PBCrossConfiguration *serviceConfig = CRConfiguration(); serviceConfig.keychainService = @"cr.quota.other-service";
    PBCrossIdentityStore *otherService = [[PBCrossIdentityStore alloc] initWithConfiguration:serviceConfig];
    PBCrossConfiguration *remoteConfig = CRConfiguration(); remoteConfig.remoteConfiguration.developerID = @"other-developer";
    PBCrossIdentityStore *otherRemote = [[PBCrossIdentityStore alloc] initWithConfiguration:remoteConfig];
    CRAssert([otherService registerRemoteRequestIfAllowed:1] && [otherRemote registerRemoteRequestIfAllowed:1],
             @"quota is isolated by Keychain service and remote developer scope");
}

static NSString *CRDayKey(NSInteger offset)
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = NSTimeZone.localTimeZone;
    NSDate *date = [calendar dateByAddingUnit:NSCalendarUnitDay value:offset toDate:NSDate.date options:0];
    NSDateComponents *day = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    return [NSString stringWithFormat:@"%04ld%02ld%02ld", (long)day.year, (long)day.month, (long)day.day];
}

static void CRVerifyQuotaUpgradeAndPruning(NSString *suite)
{
    CRReset();
    PBCrossIdentityStore *a = CRStore(suite), *b = CRStore([suite stringByAppendingString:@".peer"]);
    NSUserDefaults *aDefaults = [a valueForKey:@"standardDefaults"], *bDefaults = [b valueForKey:@"standardDefaults"];
    NSString *logKey = [a scopedDefaultsKey:[a remoteRequestLogKey]];
    for (NSUserDefaults *defaults in @[aDefaults, bDefaults]) {
        NSDictionary *log = @{@"day": CRDayKey(0), @"count": defaults == aDefaults ? @5 : @2};
        NSData *data = [NSJSONSerialization dataWithJSONObject:log options:0 error:NULL];
        [defaults setObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:logKey];
    }
    NSUInteger allowed = 0;
    for (NSUInteger i = 0; i < 8; i++) { allowed += [(i % 2 ? a : b) registerRemoteRequestIfAllowed:5]; }
    CRAssert(allowed == 5, @"upgrade starts one shared quota instead of importing divergent private legacy counts");
    [a clearStoredIdentityWithError:NULL];
    CRAssert([b registerRemoteRequestIfAllowed:1] && ![a registerRemoteRequestIfAllowed:1],
             @"a peer's old Defaults count cannot restore quota state after shared clear");

    NSString *prefix = [@"pb_remote_request_slot." stringByAppendingString:[a remoteServiceScope]];
    NSString *oldAccount = [NSString stringWithFormat:@"%@.%@.0", prefix, CRDayKey(-1)];
    NSString *todayAccount = [NSString stringWithFormat:@"%@.%@.0", prefix, CRDayKey(0)];
    NSString *futureAccount = [NSString stringWithFormat:@"%@.%@.0", prefix, CRDayKey(1)];
    NSString *unrelatedAccount = [NSString stringWithFormat:@"%@.%@.unrelated", prefix, CRDayKey(-1)];
    for (NSString *account in @[oldAccount, futureAccount, unrelatedAccount]) {
        CRRecords[CRStorageKey(account)] = NSData.data;
        CRAttributes[CRStorageKey(account)] = [@{(__bridge id)kSecAttrLabel:
            [account isEqual:unrelatedAccount] ? @"unrelated-label" : @"com.pb.crossapp.remote-request-reservation.v1"} mutableCopy];
    }
    PBCrossIdentityStore *restarted = CRStore(suite);
    CRAssert(![restarted registerRemoteRequestIfAllowed:1] && !CRRecords[CRStorageKey(oldAccount)] &&
             CRRecords[CRStorageKey(todayAccount)] && CRRecords[CRStorageKey(futureAccount)] && CRRecords[CRStorageKey(unrelatedAccount)],
             @"quota pruning removes only older SDK reservations, preserving current, future and unrelated records");
    [a clearStoredIdentityWithError:NULL];
    CRAssert(CRRecords[CRStorageKey(unrelatedAccount)] != nil, @"quota clear preserves unrelated Keychain labels");
}

static void CRVerifyClearAgainstOldLoad(NSString *suite, BOOL duringCollection)
{
    CRPrepareManager(suite);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    PBCrossIdentityStore *store = [manager valueForKey:@"storeStorage"];
    CRSystemUpdateFixture = @"new-system-time";
    if (duringCollection) {
        CRCollectionReady = dispatch_semaphore_create(0); CRCollectionRelease = dispatch_semaphore_create(0);
    } else {
        store = [[CRBlockedIdentityStore alloc] initWithConfiguration:manager.configuration];
        [store setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
        [manager setValue:store forKey:@"storeStorage"];
        CRStoreReady = dispatch_semaphore_create(0); CRStoreRelease = dispatch_semaphore_create(0);
    }
    __block BOOL loaded = NO, cleared = NO;
    [manager refreshIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
        CRAssert(identity == nil && error.code == PBCrossIdentifierErrorOperationCancelled,
                 @"clear cancels the old load without delivering an obsolete identity");
        loaded = YES;
    }];
    CRAssert(dispatch_semaphore_wait(duringCollection ? CRCollectionReady : CRStoreReady,
        dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0, @"old load reaches the clear interleaving barrier");
    if (duringCollection) {
        cleared = [manager clearStoredIdentityWithError:NULL];
        dispatch_semaphore_signal(CRCollectionRelease);
    } else {
        dispatch_semaphore_t started = dispatch_semaphore_create(0), done = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_signal(started);
            cleared = [manager clearStoredIdentityWithError:NULL];
            dispatch_semaphore_signal(done);
        });
        dispatch_semaphore_wait(started, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));
        CRAssert(dispatch_semaphore_wait(done, dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC)) != 0,
                 @"clear waits for an active identity storage operation");
        dispatch_semaphore_signal(CRStoreRelease);
        BOOL completed = dispatch_semaphore_wait(done, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC)) == 0;
        CRAssert(completed, @"clear completes after the active identity write");
        if (!completed) { exit(1); }
    }
    CRPumpUntil(^BOOL { return loaded; });
    NSUserDefaults *defaults = [store valueForKey:@"standardDefaults"];
    CRAssert(cleared && !CRRecords[CRStorageKey(CRSharedKey)] && !CRRecords[CRStorageKey(CRServerKey)] &&
             ![defaults objectForKey:[store scopedDefaultsKey:CRSharedKey]] &&
             ![defaults objectForKey:[store scopedDefaultsKey:@"pb_system_update_history"]] && !manager.cachedIdentity,
             @"old load cannot recreate Keychain identity, Defaults mirror or history after successful clear");
    CRCollectionReady = CRCollectionRelease = nil;
    CRSystemUpdateFixture = nil;
    [manager setValue:CRStore(suite) forKey:@"storeStorage"];
    CRAssert(manager.identitySynchronously.sharedID.length > 0, @"an explicit new load can create identity after clear");
}

static void CRVerifySharedGetterConfiguration(NSString *suite)
{
    CRPrepareManager(suite);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRBlockedIdentityStore *blocked = [[CRBlockedIdentityStore alloc] initWithConfiguration:manager.configuration];
    [blocked setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
    [manager setValue:blocked forKey:@"storeStorage"];
    CRRecords[CRStorageKey(CRSharedKey)] = [@"before-switch" dataUsingEncoding:NSUTF8StringEncoding];
    CRRecords[@"cr.getter.new/TEAM.cr.shared/pb_shared_id"] = [@"after-switch" dataUsingEncoding:NSUTF8StringEncoding];
    CRStoreReady = dispatch_semaphore_create(0); CRStoreRelease = dispatch_semaphore_create(0);
    dispatch_semaphore_t readDone = dispatch_semaphore_create(0), mutationStarted = dispatch_semaphore_create(0);
    dispatch_semaphore_t mutationDone = dispatch_semaphore_create(0);
    __block NSString *before = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        before = manager.sharedID;
        dispatch_semaphore_signal(readDone);
    });
    CRAssert(dispatch_semaphore_wait(CRStoreReady, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC)) == 0,
             @"sharedID read is paused inside the current storage operation");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_signal(mutationStarted);
        [manager configureWithBlock:^(PBCrossConfiguration *c) { c.keychainService = @"cr.getter.new"; } error:NULL];
        dispatch_semaphore_signal(mutationDone);
    });
    dispatch_semaphore_wait(mutationStarted, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));
    CRAssert(dispatch_semaphore_wait(mutationDone, dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC)) != 0,
             @"configuration cannot commit midway through a sharedID read/create");
    dispatch_semaphore_signal(CRStoreRelease);
    BOOL readFinished = dispatch_semaphore_wait(readDone, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC)) == 0;
    BOOL changed = dispatch_semaphore_wait(mutationDone, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC)) == 0;
    CRAssert(readFinished && changed, @"sharedID and configuration operations both finish");
    if (!readFinished || !changed) { exit(1); }
    PBCrossIdentityStore *current = [[PBCrossIdentityStore alloc] initWithConfiguration:manager.configuration];
    [current setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
    [manager setValue:current forKey:@"storeStorage"];
    CRAssert([before isEqual:@"before-switch"] && [manager.sharedID isEqual:@"after-switch"],
             @"sharedID operations serialize with configuration and reads after commit use the new namespace");
}

@interface CRChangingRemoteCacheStore : PBCrossIdentityStore
@property NSUInteger reads;
@property (nonatomic, copy) NSDictionary *initialCache;
@end
@implementation CRChangingRemoteCacheStore
- (NSDictionary *)remoteCache
{
    if (++self.reads == 1) { return self.initialCache; }
    return @{@"resolved_at": @(NSDate.date.timeIntervalSince1970),
             @"identifiers": @[@{@"id": @"peer-new-id", @"version": @"2"}]};
}
@end

static void CRVerifyRemoteCacheSnapshot(void)
{
    PBCrossConfiguration *configuration = CRConfiguration();
    configuration.remoteConfiguration.enabled = YES;
    configuration.remoteConfiguration.developerID = @"test";
    configuration.remoteConfiguration.endpointURL = [NSURL URLWithString:@"https://example.invalid"];
    configuration.remoteConfiguration.publicKey = @"unused-no-network";
    configuration.remoteConfiguration.userConsentGranted = YES;
    for (NSUInteger scenario = 0; scenario < 3; scenario++) {
        CRChangingRemoteCacheStore *store = [[CRChangingRemoteCacheStore alloc] initWithConfiguration:configuration];
        if (scenario > 0) {
            store.initialCache = @{@"resolved_at": scenario == 1 ? @1 : @(NSDate.date.timeIntervalSince1970),
                @"identifiers": @[@{@"id": @"initial-id", @"version": @"1"}]};
        }
        PBCrossRemoteResolver *resolver = [[PBCrossRemoteResolver alloc] initWithConfiguration:configuration store:store];
        __block BOOL finished = NO;
        [resolver resolveIdentifiersWithAttributes:[PBCrossDeviceAttributes attributesWithValues:@{}]
            completion:^(NSArray<PBCrossIdentifier *> *ids, NSDate *date, NSError *error) {
                BOOL correct = scenario == 2 ? (ids.count == 1 && [ids.firstObject.value isEqual:@"initial-id"] && date && !error) :
                    (!ids && !date && error.code == PBCrossRemoteErrorMissingDeviceAttributes);
                CRAssert(NSThread.isMainThread && correct && store.reads == 1,
                    @"cache freshness and returned IDs use one snapshot despite a peer cache update");
                finished = YES;
            }];
        CRPumpUntil(^BOOL { return finished; });
    }
}


// Deterministic continuations: only the real Manager/Store are exercised; the
// resolver never creates a network task and all Keychain operations stay mocked.
static dispatch_semaphore_t CRContinuationReady, CRContinuationRelease;
static IMP CROriginalCachedIdentity;
static PBCrossIdentity *CRPausedCachedIdentity(id manager, SEL selector)
{
    dispatch_semaphore_signal(CRContinuationReady);
    dispatch_semaphore_wait(CRContinuationRelease, DISPATCH_TIME_FOREVER);
    return ((PBCrossIdentity *(*)(id, SEL))CROriginalCachedIdentity)(manager, selector);
}

@interface CRControlledRemoteResolver : PBCrossRemoteResolver
@property (nonatomic, copy) PBCrossRemoteResolutionCompletion pending;
@property (nonatomic, assign) NSUInteger calls;
@end
@implementation CRControlledRemoteResolver
- (void)resolveIdentifiersWithAttributes:(PBCrossDeviceAttributes *)attributes
                              completion:(PBCrossRemoteResolutionCompletion)completion
{
    self.calls++;
    self.pending = completion;
}
@end

@interface CRPausedFreshnessResolver : CRControlledRemoteResolver
@end
@implementation CRPausedFreshnessResolver
- (BOOL)hasFreshCache
{
    dispatch_semaphore_signal(CRContinuationReady);
    dispatch_semaphore_wait(CRContinuationRelease, DISPATCH_TIME_FOREVER);
    return NO;
}
@end

static void CRWaitForContinuation(dispatch_semaphore_t ready)
{
    BOOL reached = dispatch_semaphore_wait(ready, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC)) == 0;
    CRAssert(reached, @"old request reaches the continuation barrier");
    if (!reached) { exit(1); }
}

static PBCrossIdentityStore *CRInstallCurrentStore(NSString *suite)
{
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    PBCrossIdentityStore *store = [[PBCrossIdentityStore alloc] initWithConfiguration:manager.configuration];
    [store setValue:[[NSUserDefaults alloc] initWithSuiteName:suite] forKey:@"standardDefaults"];
    [manager setValue:store forKey:@"storeStorage"];
    return store;
}

static CRControlledRemoteResolver *CRInstallResolver(PBCrossIdentityStore *store, Class resolverClass)
{
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRControlledRemoteResolver *resolver = [[resolverClass alloc] initWithConfiguration:manager.configuration store:store];
    [manager setValue:resolver forKey:@"remoteResolverStorage"];
    return resolver;
}

static PBCrossIdentityStore *CRPrepareRemoteManager(NSString *suite, BOOL automatic)
{
    CRPrepareManager(suite);
    [PBCrossAppUniqueDeviceIdentifierManager.sharedManager configureWithBlock:^(PBCrossConfiguration *c) {
        c.automaticallyRefreshesRemoteIdentity = automatic;
        c.remoteConfiguration.enabled = YES;
        c.remoteConfiguration.endpointURL = [NSURL URLWithString:@"https://example.invalid"];
        c.remoteConfiguration.developerID = @"fixture";
        c.remoteConfiguration.publicKey = @"unused-no-network";
        c.remoteConfiguration.userConsentGranted = YES;
    } error:NULL];
    return CRInstallCurrentStore(suite);
}

// mutation: 0 = keep the generation, 1 = clear, 2 = switch storage namespace.
static void CRMutateContinuation(NSString *suite, NSUInteger mutation)
{
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    if (mutation == 1) {
        NSError *error = nil;
        CRAssert([manager clearStoredIdentityWithError:&error] && !error, @"clear succeeds while old continuation is paused");
    } else if (mutation == 2) {
        CRAssert([manager configureWithBlock:^(PBCrossConfiguration *c) {
            c.keychainService = @"cr.continuation.new";
        } error:NULL], @"configuration switches while old continuation is paused");
        CRInstallCurrentStore(suite);
    } else {
        [manager resetIdentityCache];
    }
}

static void CRVerifyRemoteCompletionContinuation(NSString *suite, NSUInteger mutation, BOOL success)
{
    PBCrossIdentityStore *store = CRPrepareRemoteManager(suite, NO);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRControlledRemoteResolver *resolver = CRInstallResolver(store, CRControlledRemoteResolver.class);
    CRSystemUpdateFixture = @"continuation-system-time";
    __block NSUInteger callbacks = 0, notifications = 0;
    NSString *originalID = manager.identitySynchronously.sharedID;
    id observer = [NSNotificationCenter.defaultCenter addObserverForName:PBCrossAppUniqueDeviceIdentifierDidUpdateNotification
        object:manager queue:nil usingBlock:^(__unused NSNotification *note) { notifications++; }];
    PBCrossIdentityCompletion completion = ^(PBCrossIdentity *identity, NSError *error) {
        callbacks++;
        if (mutation) {
            CRAssert(NSThread.isMainThread && !identity && error.code == PBCrossIdentifierErrorOperationCancelled,
                     @"old remote completion delivers cancellation exactly once to each waiter");
        } else {
            CRAssert(NSThread.isMainThread && [identity.sharedID isEqual:originalID] &&
                (success ? (!error && [identity identifiersWithKind:PBCrossIdentifierKindRemote].count == 1) :
                           error.code == PBCrossRemoteErrorNetwork),
                     @"current remote completion rebuilds an evicted base identity and preserves its result");
        }
    };
    [manager resolveRemoteIdentityWithCompletion:completion];
    [manager resolveRemoteIdentityWithCompletion:completion];
    dispatch_queue_t queue = [manager valueForKey:@"workQueue"];
    dispatch_sync(queue, ^{});
    CRAssert(resolver.calls == 1 && resolver.pending != nil, @"remote waiters share one controlled resolution");
    if (!resolver.pending) { exit(1); }

    CRContinuationReady = dispatch_semaphore_create(0); CRContinuationRelease = dispatch_semaphore_create(0);
    Method method = class_getInstanceMethod(manager.class, @selector(cachedIdentity));
    CROriginalCachedIdentity = method_setImplementation(method, (IMP)CRPausedCachedIdentity);
    PBCrossIdentifier *remote = [PBCrossIdentifier identifierWithValue:@"resolved-id" version:@"1" kind:PBCrossIdentifierKindRemote];
    resolver.pending(success ? @[remote] : nil, success ? NSDate.date : nil,
                     success ? nil : [NSError errorWithDomain:PBCrossIdentifierErrorDomain code:PBCrossRemoteErrorNetwork userInfo:nil]);
    resolver.pending = nil;
    CRWaitForContinuation(CRContinuationReady);
    CRMutateContinuation(suite, mutation);
    NSDictionary *records = CRRecords.copy;
    NSUserDefaults *defaults = [store valueForKey:@"standardDefaults"];
    NSDictionary *persisted = [defaults persistentDomainForName:suite] ?: @{};
    NSUInteger adds = CRAdds, updates = CRUpdates;
    dispatch_semaphore_signal(CRContinuationRelease);
    dispatch_sync(queue, ^{});
    method_setImplementation(method, CROriginalCachedIdentity);
    CRPumpUntil(^BOOL { return callbacks == 2; });
    CRAssert(callbacks == 2 && notifications == (success && !mutation ? 1 : 0),
             @"remote completion sends no duplicate callbacks or obsolete update notifications");
    if (mutation) {
        CRAssert([records isEqual:CRRecords] && adds == CRAdds && updates == CRUpdates &&
            [persisted isEqual:([defaults persistentDomainForName:suite] ?: @{})] && !manager.cachedIdentity,
            @"old remote completion cannot create identity, mirrors, history or cache after clear/configure");
    }
    [NSNotificationCenter.defaultCenter removeObserver:observer];
    CRSystemUpdateFixture = nil;
}

static void CRVerifyAutomaticContinuation(NSString *suite, NSUInteger mutation)
{
    PBCrossIdentityStore *store = CRPrepareRemoteManager(suite, YES);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRControlledRemoteResolver *oldResolver = CRInstallResolver(store, CRPausedFreshnessResolver.class);
    CRContinuationReady = dispatch_semaphore_create(0); CRContinuationRelease = dispatch_semaphore_create(0);
    __block NSUInteger callbacks = 0;
    [manager loadIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) {
        callbacks++;
        CRAssert(!identity && error.code == PBCrossIdentifierErrorOperationCancelled,
                 @"clear/configure cancels the local result waiting for main-thread delivery");
    }];
    CRWaitForContinuation(CRContinuationReady);
    CRMutateContinuation(suite, mutation);
    CRControlledRemoteResolver *currentResolver = CRInstallResolver([manager valueForKey:@"storeStorage"], CRControlledRemoteResolver.class);
    NSDictionary *records = CRRecords.copy;
    NSUserDefaults *defaults = [store valueForKey:@"standardDefaults"];
    NSDictionary *persisted = [defaults persistentDomainForName:suite] ?: @{};
    NSUInteger collections = CRCollections, adds = CRAdds;
    dispatch_semaphore_signal(CRContinuationRelease);
    dispatch_queue_t queue = [manager valueForKey:@"workQueue"];
    // The first drain lets the old load submit its automatic continuation.
    dispatch_sync(queue, ^{}); dispatch_sync(queue, ^{});
    CRPumpUntil(^BOOL { return callbacks == 1; });
    CRAssert(callbacks == 1 && !oldResolver.calls && !currentResolver.calls && !manager.cachedIdentity &&
        collections == CRCollections && adds == CRAdds && [records isEqual:CRRecords] &&
        [persisted isEqual:([defaults persistentDomainForName:suite] ?: @{})],
        @"obsolete automatic refresh cannot recollect, create identity or invoke either resolver");

    __block BOOL loaded = NO;
    [manager loadIdentityWithCompletion:^(PBCrossIdentity *identity, NSError *error) { loaded = identity.sharedID.length > 0 && !error; }];
    dispatch_sync(queue, ^{}); dispatch_sync(queue, ^{});
    CRPumpUntil(^BOOL { return loaded; });
    CRAssert(currentResolver.calls == 1 && currentResolver.pending != nil,
             @"a new load after clear/configure still starts automatic remote resolution");
    if (!currentResolver.pending) { exit(1); }
    currentResolver.pending(nil, nil, [NSError errorWithDomain:PBCrossIdentifierErrorDomain code:PBCrossRemoteErrorNetwork userInfo:nil]);
    currentResolver.pending = nil;
    dispatch_sync(queue, ^{});
}

static void CRVerifyQueuedRequests(NSString *suite, NSUInteger mutation)
{
    PBCrossIdentityStore *store = CRPrepareRemoteManager(suite, NO);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRControlledRemoteResolver *resolver = CRInstallResolver(store, CRControlledRemoteResolver.class);
    (void)manager.identitySynchronously;
    dispatch_queue_t queue = [manager valueForKey:@"workQueue"];
    dispatch_semaphore_t ready = dispatch_semaphore_create(0), release = dispatch_semaphore_create(0);
    dispatch_async(queue, ^{ dispatch_semaphore_signal(ready); dispatch_semaphore_wait(release, DISPATCH_TIME_FOREVER); });
    CRWaitForContinuation(ready);
    __block NSUInteger callbacks = 0;
    PBCrossIdentityCompletion completion = ^(PBCrossIdentity *identity, NSError *error) {
        callbacks++;
        CRAssert(NSThread.isMainThread && !identity && error.code == PBCrossIdentifierErrorOperationCancelled,
                 @"queued load/refresh/remote request keeps its submission generation and returns cancellation");
    };
    [manager loadIdentityWithCompletion:completion];
    [manager refreshIdentityWithCompletion:completion];
    [manager resolveRemoteIdentityWithCompletion:completion];
    CRMutateContinuation(suite, mutation);
    NSDictionary *records = CRRecords.copy;
    NSUserDefaults *defaults = [store valueForKey:@"standardDefaults"];
    NSDictionary *persisted = [defaults persistentDomainForName:suite] ?: @{};
    NSUInteger collections = CRCollections, adds = CRAdds;
    dispatch_semaphore_signal(release);
    dispatch_sync(queue, ^{});
    CRPumpUntil(^BOOL { return callbacks == 3; });
    CRAssert(callbacks == 3 && !resolver.calls && collections == CRCollections && adds == CRAdds &&
        [records isEqual:CRRecords] && [persisted isEqual:([defaults persistentDomainForName:suite] ?: @{})] && !manager.cachedIdentity,
        @"requests queued before clear/configure perform no collection, persistence or remote resolution");
}

static void CRVerifyPendingRemoteCancellation(NSString *suite, NSUInteger mutation)
{
    PBCrossIdentityStore *store = CRPrepareRemoteManager(suite, NO);
    PBCrossAppUniqueDeviceIdentifierManager *manager = PBCrossAppUniqueDeviceIdentifierManager.sharedManager;
    CRControlledRemoteResolver *resolver = CRInstallResolver(store, CRControlledRemoteResolver.class);
    __block NSUInteger callbacks = 0;
    PBCrossIdentityCompletion completion = ^(PBCrossIdentity *identity, NSError *error) {
        callbacks++;
        CRAssert(NSThread.isMainThread && !identity && error.code == PBCrossIdentifierErrorOperationCancelled,
                 @"clear/configure cancels in-flight remote waiters with OperationCancelled");
    };
    [manager resolveRemoteIdentityWithCompletion:completion];
    [manager resolveRemoteIdentityWithCompletion:completion];
    dispatch_queue_t queue = [manager valueForKey:@"workQueue"];
    dispatch_sync(queue, ^{});
    CRAssert(resolver.calls == 1 && resolver.pending != nil, @"remote waiters are registered before cancellation");
    if (!resolver.pending) { exit(1); }
    CRMutateContinuation(suite, mutation);
    NSDictionary *records = CRRecords.copy;
    PBCrossIdentifier *late = [PBCrossIdentifier identifierWithValue:@"late-id" version:@"1" kind:PBCrossIdentifierKindRemote];
    resolver.pending(@[late], NSDate.date, nil);
    resolver.pending = nil;
    dispatch_sync(queue, ^{});
    CRPumpUntil(^BOOL { return callbacks == 2; });
    CRAssert(callbacks == 2 && [records isEqual:CRRecords] && !manager.cachedIdentity,
             @"late resolver completion cannot duplicate cancellation or restore an identity");
}

int main(void)
{
    @autoreleasepool {
        CRLock = [NSObject new];
        NSString *suite = [@"cr.pbcross.storage." stringByAppendingString:NSUUID.UUID.UUIDString];
        CRVerifyDefaultGroupIsolation(suite);
        CRVerifyConcurrentPriorityRemoval(suite);
        CRVerifySharedCacheAuthority(suite);
        CRVerifyAtomicRequestQuota(suite);
        CRVerifyQuotaUpgradeAndPruning(suite);
        CRVerifyReadFailures(suite);
        CRVerifyCreation(suite);
        CRVerifyConcurrentCreation(suite, [suite stringByAppendingString:@".peer"]);
        CRVerifyMirrorsAndNamespace(suite);
        CRVerifyMutationFailures(suite);
        CRVerifyLateRemote(suite, NO);
        CRVerifyLateRemote(suite, YES);
        CRVerifyServerInjectionRace(suite, NO);
        CRVerifyServerInjectionRace(suite, YES);
        CRVerifyAppGroupConfiguration(suite);
        CRVerifyAdvertisingRevocation(suite);
        CRVerifyConfigurationRace(suite, YES);
        CRVerifyConfigurationRace(suite, NO);
        CRVerifyStaleStoreCannotChangeCache(suite, NO);
        CRVerifyStaleStoreCannotChangeCache(suite, YES);
        CRVerifySynchronousConfigurationRetry(suite);
        CRVerifyClearAgainstOldLoad(suite, YES);
        CRVerifyClearAgainstOldLoad(suite, NO);
        CRVerifySharedGetterConfiguration(suite);
        CRVerifyRemoteCacheSnapshot();
        for (NSUInteger mutation = 0; mutation < 3; mutation++) {
            CRVerifyRemoteCompletionContinuation(suite, mutation, YES);
            CRVerifyRemoteCompletionContinuation(suite, mutation, NO);
            if (mutation) {
                CRVerifyAutomaticContinuation(suite, mutation);
                CRVerifyQueuedRequests(suite, mutation);
                CRVerifyPendingRemoteCancellation(suite, mutation);
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            fprintf(stderr, "FAIL manager callbacks timed out\n");
            exit(1);
        });
        CRVerifyManagerRecovery(suite);
        // Keep the main thread available for the manager's asynchronous callbacks.
        while (YES) { @autoreleasepool { [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]]; } }
    }
}
