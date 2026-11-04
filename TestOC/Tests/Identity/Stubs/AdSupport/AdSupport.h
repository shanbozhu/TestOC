#import <Foundation/Foundation.h>
@interface ASIdentifierManager : NSObject
@property(class,nonatomic,readonly) ASIdentifierManager *sharedManager;
@property(nonatomic,readonly) BOOL advertisingTrackingEnabled;
@property(nonatomic,readonly) NSUUID *advertisingIdentifier;
@end
