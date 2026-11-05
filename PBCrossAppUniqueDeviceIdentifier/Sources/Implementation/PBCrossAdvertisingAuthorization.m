#import "PBCrossAdvertisingAuthorization.h"

@protocol PBCrossTrackingAuthorizationClass <NSObject>
+ (NSInteger)trackingAuthorizationStatus;
@end

@protocol PBCrossAdvertisingIdentifierManager <NSObject>
+ (id)sharedManager;
- (BOOL)isAdvertisingTrackingEnabled;
- (NSUUID *)advertisingIdentifier;
@end

BOOL PBCrossAdvertisingIdentifierIsAuthorized(void)
{
    if (@available(iOS 14.0, *)) {
        Class trackingManager = NSClassFromString(@"ATTrackingManager");
        // 缺少 ATT 框架时也不能复用以前采集到的广告标识。
        return [trackingManager respondsToSelector:@selector(trackingAuthorizationStatus)]
            && [(id<PBCrossTrackingAuthorizationClass>)trackingManager trackingAuthorizationStatus] == 3;
    }

    Class managerClass = NSClassFromString(@"ASIdentifierManager");
    if (![managerClass respondsToSelector:@selector(sharedManager)]) {
        return NO;
    }
    id<PBCrossAdvertisingIdentifierManager> manager =
        [(id<PBCrossAdvertisingIdentifierManager>)managerClass sharedManager];
    return [manager respondsToSelector:@selector(isAdvertisingTrackingEnabled)]
        && manager.isAdvertisingTrackingEnabled;
}

NSString * _Nullable PBCrossReadAuthorizedAdvertisingIdentifier(void)
{
    // iOS 14+ uses ATT exclusively. The legacy switch is checked only in the
    // pre-iOS 14 branch of PBCrossAdvertisingIdentifierIsAuthorized().
    if (!PBCrossAdvertisingIdentifierIsAuthorized()) {
        return nil;
    }

    Class managerClass = NSClassFromString(@"ASIdentifierManager");
    if (![managerClass respondsToSelector:@selector(sharedManager)]) {
        return nil;
    }
    id<PBCrossAdvertisingIdentifierManager> manager =
        [(id<PBCrossAdvertisingIdentifierManager>)managerClass sharedManager];
    if (![manager respondsToSelector:@selector(advertisingIdentifier)]) {
        return nil;
    }

    NSUUID *identifier = manager.advertisingIdentifier;
    if (![identifier isKindOfClass:NSUUID.class]) {
        return nil;
    }
    NSString *value = identifier.UUIDString;
    if (value.length == 0 || [value isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        return nil;
    }
    // Hash the standard uppercase UUID, preserving the existing MD5 contract.
    return value;
}
