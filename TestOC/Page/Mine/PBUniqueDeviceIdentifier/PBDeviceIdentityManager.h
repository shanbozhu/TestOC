#import <Foundation/Foundation.h>
#import "PBDeviceIdentityStorage.h"

NS_ASSUME_NONNULL_BEGIN

/// Called on the main thread on every refresh; injectable for deterministic tests.
@protocol PBDeviceIdentityEnvironment <NSObject>
- (NSDictionary<NSString *, NSString *> *)currentIdentityFields;
@end

@interface PBDeviceIdentitySnapshot : NSObject
/// Upload example only. Unavailable identifiers are omitted, never substituted.
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *payload;
/// Local diagnostic metadata; not part of the upload contract.
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *diagnostics;
@end

typedef void (^PBDeviceIdentityCompletion)(PBDeviceIdentitySnapshot *snapshot);
typedef void (^PBDeviceIdentityMutationCompletion)(PBDeviceIdentitySnapshot *snapshot, NSError * _Nullable error);

@interface PBDeviceIdentityManager : NSObject
@property (class, nonatomic, readonly) PBDeviceIdentityManager *sharedManager;

/// Storage runs on a private serial queue; every completion runs on the main queue.
- (void)refreshWithCompletion:(PBDeviceIdentityCompletion)completion;
/// Explicit user action only. Does not prompt on refresh or app launch.
- (void)requestTrackingAuthorizationWithCompletion:(void (^)(NSError * _Nullable error))completion;
/// Demo-only: deletes this module's installation file, preserving its Keychain item.
- (void)simulateReinstallationWithCompletion:(PBDeviceIdentityMutationCompletion)completion;
/// Demo-only: deletes only this module's two IDs, never the app's other Keychain data.
- (void)resetDemoIdentityWithCompletion:(PBDeviceIdentityMutationCompletion)completion;

/// Isolated stores/environments support tests without changing the real demo identity.
- (instancetype)initWithStorage:(id<PBDeviceIdentityStorage>)storage
                    environment:(id<PBDeviceIdentityEnvironment>)environment NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
