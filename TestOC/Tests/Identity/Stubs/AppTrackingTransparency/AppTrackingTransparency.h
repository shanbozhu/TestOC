#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ATTrackingManagerAuthorizationStatus) { ATTrackingManagerAuthorizationStatusNotDetermined=0, ATTrackingManagerAuthorizationStatusRestricted=1, ATTrackingManagerAuthorizationStatusDenied=2, ATTrackingManagerAuthorizationStatusAuthorized=3 };
@interface ATTrackingManager : NSObject
@property(class,nonatomic,readonly) ATTrackingManagerAuthorizationStatus trackingAuthorizationStatus;
+ (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(ATTrackingManagerAuthorizationStatus))completion;
@end
