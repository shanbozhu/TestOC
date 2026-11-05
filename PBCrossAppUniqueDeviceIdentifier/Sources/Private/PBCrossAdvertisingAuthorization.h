#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 当前系统是否允许使用广告标识；不请求授权，不读取 IDFA。
FOUNDATION_EXPORT BOOL PBCrossAdvertisingIdentifierIsAuthorized(void);

/// 按当前系统授权读取非全零 IDFA；不请求授权，返回标准大写 UUID。
FOUNDATION_EXPORT NSString * _Nullable PBCrossReadAuthorizedAdvertisingIdentifier(void);

NS_ASSUME_NONNULL_END
