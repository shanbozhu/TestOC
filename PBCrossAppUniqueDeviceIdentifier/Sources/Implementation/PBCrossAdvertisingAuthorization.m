#import "PBCrossAdvertisingAuthorization.h"

@protocol PBCrossTrackingAuthorizationClass <NSObject>
+ (NSInteger)trackingAuthorizationStatus;
@end

@protocol PBCrossLegacyAdvertisingAuthorization <NSObject>
+ (id)sharedManager;
- (BOOL)isAdvertisingTrackingEnabled;
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
    id<PBCrossLegacyAdvertisingAuthorization> manager =
        [(id<PBCrossLegacyAdvertisingAuthorization>)managerClass sharedManager];
    return [manager respondsToSelector:@selector(isAdvertisingTrackingEnabled)]
        && manager.isAdvertisingTrackingEnabled;
}
