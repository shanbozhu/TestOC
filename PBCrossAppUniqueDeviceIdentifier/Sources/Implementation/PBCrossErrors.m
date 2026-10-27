//
//  PBCrossErrors.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossErrors.h"
#import "PBCrossConfiguration.h"

NSError *PBCrossErrorMake(NSInteger code, NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString *description = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);

    return [NSError errorWithDomain:PBCrossIdentifierErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description ?: @""}];
}

NSString *PBCrossRemoteErrorDescription(NSInteger code)
{
    switch ((PBCrossRemoteErrorCode)code) {
        case PBCrossRemoteErrorNotConfigured:
            return @"远端自建 ID 服务未配置或未启用";
        case PBCrossRemoteErrorConsentRequired:
            return @"用户尚未同意设备信息上报，已跳过远端解析";
        case PBCrossRemoteErrorDailyLimitExceeded:
            return @"已达到每设备每日远端请求上限";
        case PBCrossRemoteErrorMissingDeviceAttributes:
            return @"缺少远端解析所需的设备属性";
        case PBCrossRemoteErrorInvalidPublicKey:
            return @"服务端公钥无效";
        case PBCrossRemoteErrorEncryptionFailed:
            return @"设备信息加密失败";
        case PBCrossRemoteErrorNetwork:
            return @"网络请求失败";
        case PBCrossRemoteErrorInvalidResponse:
            return @"服务端返回格式错误";
        case PBCrossRemoteErrorDecryptionFailed:
            return @"服务端数据解密失败";
        case PBCrossRemoteErrorServerCode:
            return @"服务端返回错误码";
        case PBCrossRemoteErrorInvalidEndpoint:
            return @"服务地址无效";
        default:
            return @"未知错误";
    }
}
