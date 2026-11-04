// Exercise the real comparison helper without UIKit, ATT, DeviceCheck or Keychain access.
#import "PBUniqueIdentifierHelper.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <DeviceCheck/DeviceCheck.h>

static ATTrackingManagerAuthorizationStatus CRStatus;
static BOOL CRZeroIDFA;
static NSUInteger CRAdvertisingReads;

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
    int failures = 0;
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
