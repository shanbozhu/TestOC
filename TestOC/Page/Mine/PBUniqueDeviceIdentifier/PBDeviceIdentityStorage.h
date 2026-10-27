#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// All calls are serialized by PBDeviceIdentityManager. A failed read must never
/// be interpreted as a missing record or replaced with a fresh identifier.
@protocol PBDeviceIdentityStorage <NSObject>
- (nullable NSString *)appDeviceIdentifierWithError:(NSError **)error;
- (nullable NSString *)installationIdentifierWithError:(NSError **)error;
- (BOOL)removeAppDeviceIdentifierWithError:(NSError **)error;
- (BOOL)removeInstallationIdentifierWithError:(NSError **)error;
@end

/// App-local storage: non-synchronizing, ThisDeviceOnly Keychain + excluded-backup file.
@interface PBDeviceIdentityStorage : NSObject <PBDeviceIdentityStorage>
- (instancetype)initWithNamespace:(NSString *)namespace
                    directoryURL:(NSURL *)directoryURL NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
