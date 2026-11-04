// Isolated manager regressions; storage and system frameworks are replaced by fixtures.

#import "PBDeviceIdentityManager.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@implementation UIDevice
+ (UIDevice *)currentDevice { return [self new]; }
- (NSUUID *)identifierForVendor { return nil; }
@end
@implementation UIApplication
+ (UIApplication *)sharedApplication { return [self new]; }
- (UIApplicationState)applicationState { return UIApplicationStateActive; }
@end
@implementation ASIdentifierManager
+ (ASIdentifierManager *)sharedManager { return [self new]; }
- (BOOL)advertisingTrackingEnabled { return NO; }
- (NSUUID *)advertisingIdentifier { return nil; }
@end
@implementation ATTrackingManager
+ (ATTrackingManagerAuthorizationStatus)trackingAuthorizationStatus { return ATTrackingManagerAuthorizationStatusDenied; }
+ (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(ATTrackingManagerAuthorizationStatus))c { c(ATTrackingManagerAuthorizationStatusDenied); }
@end
@implementation PBDeviceIdentityStorage
- (instancetype)initWithNamespace:(NSString *)name directoryURL:(NSURL *)url {return [super init];}
- (NSString *)appDeviceIdentifierWithError:(NSError **)error {return nil;}
- (NSString *)installationIdentifierWithError:(NSError **)error {return nil;}
- (BOOL)removeAppDeviceIdentifierWithError:(NSError **)error {return YES;}
- (BOOL)removeInstallationIdentifierWithError:(NSError **)error {return YES;}
@end
@interface CRStorage : NSObject <PBDeviceIdentityStorage>
@property BOOL failInstall;
@property BOOL failApp;
@end
@implementation CRStorage
- (NSString *)appDeviceIdentifierWithError:(NSError **)e {
 if (_failApp) { if(e) *e=[NSError errorWithDomain:NSOSStatusErrorDomain code:-25308 userInfo:nil]; return nil; }
 return @"c62ddfaf-ad51-4621-bf36-ee2db47ac632";
}
- (NSString *)installationIdentifierWithError:(NSError **)e {
 if (_failInstall) { if(e) *e=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:nil]; return nil; }
 return @"b19cc5da-5412-4782-8394-22b7c49bef58";
}
- (BOOL)removeAppDeviceIdentifierWithError:(NSError **)e {_failApp=YES;return YES;}
- (BOOL)removeInstallationIdentifierWithError:(NSError **)e {_failInstall=YES;return YES;}
@end
@interface CREnv : NSObject <PBDeviceIdentityEnvironment>
@end
@implementation CREnv
- (NSDictionary *)currentIdentityFields {return @{@"app_bundle":@"cr.test",@"att_status":@"denied"};}
@end
static int CRResetReview(void) { @autoreleasepool {
 CRStorage *storage=[CRStorage new];
 PBDeviceIdentityManager *m=[[PBDeviceIdentityManager alloc] initWithStorage:storage environment:[CREnv new]];
 __block BOOL done=NO, passed=YES;
 [m simulateReinstallationWithCompletion:^(PBDeviceIdentitySnapshot *s,NSError *e) {
    passed = passed && e.code == NSFileWriteOutOfSpaceError && [s.payload[@"identity_status"] isEqual:@"partial"];
    printf("REINSTALL: callback error=%s status=%s diagnostics=%s\n",e.description.UTF8String,[s.payload[@"identity_status"] UTF8String],s.diagnostics.description.UTF8String);
    [m resetDemoIdentityWithCompletion:^(PBDeviceIdentitySnapshot *s,NSError *e) {
        passed = passed && e.code == -25308 && [s.payload[@"identity_status"] isEqual:@"unavailable"];
        printf("RESET: callback error=%s status=%s diagnostics=%s\n",e.description.UTF8String,[s.payload[@"identity_status"] UTF8String],s.diagnostics.description.UTF8String);
        done=YES;
    }];
 }];
 NSDate *limit=[NSDate dateWithTimeIntervalSinceNow:5];
 while(!done && limit.timeIntervalSinceNow>0) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
 printf("%s reset recreation failures propagate to the page\n", passed && done ? "PASS" : "FAIL");
 return done && passed ? 0 : 1;
}}

static dispatch_semaphore_t CRReadReady, CRReadRelease;
@interface CRBlockingReadStorage : CRStorage
@end
@implementation CRBlockingReadStorage
- (NSString *)appDeviceIdentifierWithError:(NSError **)error {
    dispatch_semaphore_signal(CRReadReady);
    dispatch_semaphore_wait(CRReadRelease, dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC));
    return [super appDeviceIdentifierWithError:error];
}
@end
@interface CRMutableEnv : NSObject <PBDeviceIdentityEnvironment>
@property BOOL authorized;
@end
@implementation CRMutableEnv
- (NSDictionary *)currentIdentityFields {
    return self.authorized ? @{@"app_bundle":@"cr.test", @"att_status":@"authorized", @"idfa":@"6ABF0056-2C6A-4378-9E80-9143C2669683"} : @{@"app_bundle":@"cr.test", @"att_status":@"denied"};
}
@end
static int CRVerifyAuthorization(BOOL mutation) { @autoreleasepool {
    CRReadReady=dispatch_semaphore_create(0); CRReadRelease=dispatch_semaphore_create(0);
    CRMutableEnv *env=[CRMutableEnv new];env.authorized=YES;
    PBDeviceIdentityManager *m=[[PBDeviceIdentityManager alloc] initWithStorage:[CRBlockingReadStorage new] environment:env];
    __block BOOL done=NO, reproduced=NO;
    void (^accept)(PBDeviceIdentitySnapshot *) = ^(PBDeviceIdentitySnapshot *snapshot) {
        reproduced=!env.authorized && snapshot.payload[@"idfa"]==nil && [snapshot.payload[@"att_status"] isEqual:@"denied"];
        printf("DELAYED AUTH SNAPSHOT: current=%s delivered=%s idfa=%s\n",[env.currentIdentityFields[@"att_status"] UTF8String],[snapshot.payload[@"att_status"] UTF8String],[snapshot.payload[@"idfa"] UTF8String]);
        printf("%s pending refresh rechecks authorization and removes revoked IDFA\n",reproduced?"PASS":"FAIL");done=YES;
    };
    if (mutation) {
        [m simulateReinstallationWithCompletion:^(PBDeviceIdentitySnapshot *snapshot, NSError *error) { accept(snapshot); }];
    } else { [m refreshWithCompletion:accept]; }
    NSDate *limit=[NSDate dateWithTimeIntervalSinceNow:3];
    BOOL blocked=NO;
    while (!blocked && limit.timeIntervalSinceNow>0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
        blocked=dispatch_semaphore_wait(CRReadReady,DISPATCH_TIME_NOW)==0;
    }
    env.authorized=NO;
    dispatch_semaphore_signal(CRReadRelease);
    while(!done && limit.timeIntervalSinceNow>0) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    return !blocked || !done || !reproduced;
}}

int main(void) { @autoreleasepool {
    int reset = CRResetReview();
    int refresh = CRVerifyAuthorization(NO);
    int mutation = CRVerifyAuthorization(YES);
    return reset || refresh || mutation;
}}
