#import "PBDeviceIdentityManager.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <Security/Security.h>

@interface PBSystemIdentityEnvironment : NSObject <PBDeviceIdentityEnvironment>
@end

@implementation PBSystemIdentityEnvironment
- (NSDictionary<NSString *, NSString *> *)currentIdentityFields {
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    fields[@"app_bundle"] = NSBundle.mainBundle.bundleIdentifier ?: @"";
    fields[@"idfv"] = UIDevice.currentDevice.identifierForVendor.UUIDString ?: @"";
    BOOL canReadIDFA = NO;
    if (@available(iOS 14.0, *)) {
        switch (ATTrackingManager.trackingAuthorizationStatus) {
            case ATTrackingManagerAuthorizationStatusAuthorized:
                fields[@"att_status"] = @"authorized"; canReadIDFA = YES; break;
            case ATTrackingManagerAuthorizationStatusDenied:
                fields[@"att_status"] = @"denied"; break;
            case ATTrackingManagerAuthorizationStatusRestricted:
                fields[@"att_status"] = @"restricted"; break;
            case ATTrackingManagerAuthorizationStatusNotDetermined:
                fields[@"att_status"] = @"not_determined"; break;
        }
    } else {
        fields[@"att_status"] = @"not_required";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        canReadIDFA = ASIdentifierManager.sharedManager.advertisingTrackingEnabled;
#pragma clang diagnostic pop
    }
    if (canReadIDFA) {
        fields[@"idfa"] = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString ?: @"";
    }
    return fields.copy;
}
@end

@interface PBDeviceIdentitySnapshot ()
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, id> *payload;
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, id> *diagnostics;
@end
@implementation PBDeviceIdentitySnapshot
@end

@interface PBDeviceIdentityManager ()
@property (nonatomic, strong) id<PBDeviceIdentityStorage> storage;
@property (nonatomic, strong) id<PBDeviceIdentityEnvironment> environment;
@property (nonatomic, strong) dispatch_queue_t storageQueue;
@property (nonatomic, assign) BOOL authorizationRequestInFlight; // Main thread only.
@end

@implementation PBDeviceIdentityManager

+ (instancetype)sharedManager {
    static PBDeviceIdentityManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundle = NSBundle.mainBundle.bundleIdentifier;
        NSAssert(bundle.length > 0, @"A host bundle identifier is required for app-local identity");
        NSURL *support = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory
                                                            inDomains:NSUserDomainMask].firstObject;
        NSURL *directory = [support URLByAppendingPathComponent:@"PBUniqueDeviceIdentifier" isDirectory:YES];
        PBDeviceIdentityStorage *storage = [[PBDeviceIdentityStorage alloc]
            initWithNamespace:[bundle stringByAppendingString:@".pb.identity.v1"] directoryURL:directory];
        manager = [[self alloc] initWithStorage:storage environment:[PBSystemIdentityEnvironment new]];
    });
    return manager;
}

- (instancetype)initWithStorage:(id<PBDeviceIdentityStorage>)storage
                    environment:(id<PBDeviceIdentityEnvironment>)environment {
    NSParameterAssert(storage);
    NSParameterAssert(environment);
    self = [super init];
    if (self) {
        _storage = storage;
        _environment = environment;
        _storageQueue = dispatch_queue_create("com.pb.device-identity.storage", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (nullable NSString *)validUUID:(NSString *)value {
    NSUUID *uuid = value.length ? [[NSUUID alloc] initWithUUIDString:value] : nil;
    if ([uuid.UUIDString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) { return nil; }
    return uuid.UUIDString.lowercaseString;
}

- (NSDictionary *)diagnosticForError:(NSError *)error {
    return @{ @"domain": error.domain, @"code": @(error.code), @"message": error.localizedDescription };
}

- (NSString *)statusForIdentifier:(NSString *)identifier error:(NSError *)error {
    if (identifier.length) { return @"available"; }
    if ([error.domain isEqualToString:NSOSStatusErrorDomain] &&
        (error.code == errSecInteractionNotAllowed || error.code == errSecNotAvailable)) {
        return @"temporarily_unavailable";
    }
    if ([error.domain isEqualToString:NSCocoaErrorDomain] &&
        (error.code == NSFileReadNoPermissionError || error.code == NSFileWriteNoPermissionError)) {
        return @"temporarily_unavailable";
    }
    return @"unavailable";
}

- (PBDeviceIdentitySnapshot *)snapshotWithFields:(NSDictionary<NSString *, NSString *> *)fields {
    NSError *appError = nil;
    NSError *installError = nil;
    NSString *appID = [self validUUID:[self.storage appDeviceIdentifierWithError:&appError]];
    NSString *installID = [self validUUID:[self.storage installationIdentifierWithError:&installError]];
    NSString *appStatus = [self statusForIdentifier:appID error:appError];
    NSString *installStatus = [self statusForIdentifier:installID error:installError];
    NSString *att = fields[@"att_status"] ?: @"unknown";
    NSMutableDictionary *payload = [@{ @"identity_version": @1,
                                      @"identity_scope": @"app",
                                      @"app_bundle": fields[@"app_bundle"] ?: @"",
                                      @"att_status": att,
                                      @"app_device_id_status": appStatus,
                                      @"installation_id_status": installStatus } mutableCopy];
    payload[@"identity_status"] = (appID && installID) ? @"available" : (appID || installID) ? @"partial" : @"unavailable";
    if (appID) { payload[@"app_device_id"] = appID; }
    if (installID) { payload[@"installation_id"] = installID; }
    NSString *idfv = [self validUUID:fields[@"idfv"]];
    payload[@"idfv_status"] = idfv ? @"available" : @"temporarily_unavailable";
    if (idfv) { payload[@"idfv"] = idfv; }
    // Recheck authorization every time. Never retain an old IDFA after revocation.
    if ([att isEqualToString:@"authorized"] || [att isEqualToString:@"not_required"]) {
        NSString *idfa = [self validUUID:fields[@"idfa"]];
        if (idfa) { payload[@"idfa"] = idfa; }
    }
    NSMutableDictionary *diagnostics = [NSMutableDictionary dictionary];
    diagnostics[@"collected_at"] = [[NSISO8601DateFormatter new] stringFromDate:NSDate.date];
    if (appError) { diagnostics[@"app_device_id_error"] = [self diagnosticForError:appError]; }
    if (installError) { diagnostics[@"installation_id_error"] = [self diagnosticForError:installError]; }
    PBDeviceIdentitySnapshot *snapshot = [PBDeviceIdentitySnapshot new];
    snapshot.payload = payload;
    snapshot.diagnostics = diagnostics;
    return snapshot;
}

- (void)refreshWithCompletion:(PBDeviceIdentityCompletion)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *fields = [self.environment currentIdentityFields];
        dispatch_async(self.storageQueue, ^{
            PBDeviceIdentitySnapshot *snapshot = [self snapshotWithFields:fields];
            dispatch_async(dispatch_get_main_queue(), ^{ completion(snapshot); });
        });
    });
}

- (void)requestTrackingAuthorizationWithCompletion:(void (^)(NSError * _Nullable))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 14.0, *)) {
            if (ATTrackingManager.trackingAuthorizationStatus != ATTrackingManagerAuthorizationStatusNotDetermined) {
                completion(nil);
                return;
            }
            NSString *message = nil;
            NSString *usage = [NSBundle.mainBundle objectForInfoDictionaryKey:@"NSUserTrackingUsageDescription"];
            if (usage.length == 0) { message = @"宿主缺少 NSUserTrackingUsageDescription，不能请求 ATT"; }
            else if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
                message = @"请在 App 前台激活后重试";
            } else if (self.authorizationRequestInFlight) { message = @"已有 ATT 请求正在进行"; }
            if (message) {
                completion([NSError errorWithDomain:@"PBDeviceIdentityAuthorization" code:1
                                           userInfo:@{NSLocalizedDescriptionKey: message}]);
                return;
            }
            self.authorizationRequestInFlight = YES;
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(__unused ATTrackingManagerAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.authorizationRequestInFlight = NO;
                    completion(nil);
                });
            }];
        } else { completion(nil); }
    });
}

- (void)performResetIncludingKeychain:(BOOL)includingKeychain completion:(PBDeviceIdentityMutationCompletion)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *fields = [self.environment currentIdentityFields];
        dispatch_async(self.storageQueue, ^{
            NSError *error = nil;
            BOOL success = !includingKeychain || [self.storage removeAppDeviceIdentifierWithError:&error];
            if (success) { success = [self.storage removeInstallationIdentifierWithError:&error]; }
            // Reads after failure preserve valid records; never claim a successful reset.
            PBDeviceIdentitySnapshot *snapshot = [self snapshotWithFields:fields];
            if (!success && !error) {
                error = [NSError errorWithDomain:@"PBDeviceIdentityMutation" code:1
                                       userInfo:@{NSLocalizedDescriptionKey: @"重置未完成"}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{ completion(snapshot, error); });
        });
    });
}

- (void)simulateReinstallationWithCompletion:(PBDeviceIdentityMutationCompletion)completion {
    [self performResetIncludingKeychain:NO completion:completion];
}

- (void)resetDemoIdentityWithCompletion:(PBDeviceIdentityMutationCompletion)completion {
    [self performResetIncludingKeychain:YES completion:completion];
}

@end
