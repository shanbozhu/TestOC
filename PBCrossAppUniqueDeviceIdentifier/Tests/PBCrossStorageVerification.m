#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "PBCrossIdentityStore.h"
#import "PBCrossAppUniqueDeviceIdentifierManager.h"
#import "PBCrossDeviceAttributeCollector.h"

static NSString * const CRSharedKey = @"pb_shared_id";
static NSString * const CRServerKey = @"pb_server_shared_id";
static NSObject *CRLock;
static NSMutableDictionary<NSString *, id> *CRRecords;
static NSMutableDictionary<NSString *, NSNumber *> *CRReadErrors;
static OSStatus CRAddError;
static NSUInteger CRAdds, CRUpdates, CRPrivateQueries;
static BOOL CRInjectDuplicate, CRFailWinnerRead;
static dispatch_semaphore_t CRRaceReady, CRRaceRelease;
static NSUInteger CRRaceReaders;
static int CRFailures;

static NSString *CRRecordKey(NSDictionary *query)
{
    NSString *group = query[(__bridge id)kSecAttrAccessGroup] ?: @"private";
    return [NSString stringWithFormat:@"%@/%@/%@", query[(__bridge id)kSecAttrService],
            group, query[(__bridge id)kSecAttrAccount]];
}

// Each SecItem operation is atomic. Independent stores model separate app
// processes, while barriers force both initial reads to observe no record.
// No real Keychain or production UserDefaults are touched by this executable.
OSStatus SecItemCopyMatching(CFDictionaryRef rawQuery, CFTypeRef *result)
{
    NSDictionary *query = (__bridge NSDictionary *)rawQuery;
    NSString *account = query[(__bridge id)kSecAttrAccount];
    BOOL waitForPeer = NO;
    @synchronized(CRLock) {
        if (!query[(__bridge id)kSecAttrAccessGroup]) { CRPrivateQueries++; }
        NSNumber *failure = CRReadErrors[account];
        if (failure) { return failure.intValue; }
        id data = CRRecords[CRRecordKey(query)];
        if (data) {
            if (result) { *result = CFBridgingRetain(data); }
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
    @synchronized(CRLock) {
        CRAdds++;
        if (CRAddError) { return CRAddError; }
        NSString *key = CRRecordKey(query);
        if (CRInjectDuplicate) {
            CRInjectDuplicate = NO;
            CRRecords[key] = [@"persisted-winner" dataUsingEncoding:NSUTF8StringEncoding];
            if (CRFailWinnerRead) { CRReadErrors[CRSharedKey] = @(errSecInteractionNotAllowed); }
        }
        if (CRRecords[key]) { return errSecDuplicateItem; }
        CRRecords[key] = query[(__bridge id)kSecValueData];
        return errSecSuccess;
    }
}

OSStatus SecItemUpdate(CFDictionaryRef rawQuery, CFDictionaryRef rawAttributes)
{
    @synchronized(CRLock) {
        CRUpdates++;
        NSString *key = CRRecordKey((__bridge NSDictionary *)rawQuery);
        if (!CRRecords[key]) { return errSecItemNotFound; }
        CRRecords[key] = ((__bridge NSDictionary *)rawAttributes)[(__bridge id)kSecValueData];
        return errSecSuccess;
    }
}

OSStatus SecItemDelete(CFDictionaryRef rawQuery)
{
    @synchronized(CRLock) {
        [CRRecords removeObjectForKey:CRRecordKey((__bridge NSDictionary *)rawQuery)];
        return errSecSuccess;
    }
}

// The manager uses real storage/generator/cache code; device collection is
// deterministic here so the regression suite can run on macOS without UIKit.
@implementation PBCrossDeviceAttributeCollector
+ (PBCrossDeviceAttributes *)collectAttributesWithConfiguration:(PBCrossConfiguration *)configuration
{
    return [PBCrossDeviceAttributes attributesWithValues:@{PBCrossAttributeKeyMachine: @"test-device"}];
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
    CRReadErrors = [NSMutableDictionary dictionary];
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
    CRAssert([value isEqual:@"legacy-id"] && !error && CRAdds == 1 && CRUpdates == 0,
             @"legacy Defaults identity migrates through an atomic add");

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
                     [[defaults stringForKey:CRSharedKey] isEqual:value], @"duplicate creation returns and mirrors the winner");
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
    CRAssert([[defaultsA stringForKey:CRSharedKey] isEqual:persisted] && [[defaultsB stringForKey:CRSharedKey] isEqual:persisted],
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

int main(void)
{
    @autoreleasepool {
        CRLock = [NSObject new];
        NSString *suite = [@"cr.pbcross.storage." stringByAppendingString:NSUUID.UUID.UUIDString];
        CRVerifyReadFailures(suite);
        CRVerifyCreation(suite);
        CRVerifyConcurrentCreation(suite, [suite stringByAppendingString:@".peer"]);
        CRVerifyAppGroupConfiguration(suite);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            fprintf(stderr, "FAIL manager callbacks timed out\n");
            exit(1);
        });
        CRVerifyManagerRecovery(suite);
        // Keep the main thread available for the manager's asynchronous callbacks.
        while (YES) { @autoreleasepool { [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]]; } }
    }
}
