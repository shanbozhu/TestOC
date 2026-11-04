#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, UIApplicationState) { UIApplicationStateActive=0, UIApplicationStateInactive=1, UIApplicationStateBackground=2 };
@interface UIDevice : NSObject
@property(class,nonatomic,readonly) UIDevice *currentDevice;
@property(nonatomic,readonly) NSUUID *identifierForVendor;
@end
@interface UIApplication : NSObject
@property(class,nonatomic,readonly) UIApplication *sharedApplication;
@property(nonatomic,readonly) UIApplicationState applicationState;
@end
