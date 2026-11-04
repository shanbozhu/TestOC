#import <Foundation/Foundation.h>
@interface DCDevice : NSObject
@property (class, nonatomic, readonly) DCDevice *currentDevice;
@property (nonatomic, readonly, getter=isSupported) BOOL supported;
- (void)generateTokenWithCompletionHandler:(void (^)(NSData *, NSError *))completion;
@end
