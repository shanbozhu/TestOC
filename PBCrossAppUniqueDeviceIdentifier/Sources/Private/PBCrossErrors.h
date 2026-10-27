//
//  PBCrossErrors.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 构造 PBCrossIdentifierErrorDomain 下的错误。
FOUNDATION_EXPORT NSError *PBCrossErrorMake(NSInteger code, NSString *format, ...) NS_FORMAT_FUNCTION(2, 3);

/// 远端错误码的默认文案。
FOUNDATION_EXPORT NSString *PBCrossRemoteErrorDescription(NSInteger code);

NS_ASSUME_NONNULL_END
