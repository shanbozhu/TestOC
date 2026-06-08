//
//  PBDeviceCheckExample.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/8.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBDeviceCheckExample.h"
#import <DeviceCheck/DeviceCheck.h>

@implementation PBDeviceCheckStepResult
@end

@implementation PBDeviceCheckExample

#pragma mark - Public

+ (void)runWorkflowExampleWithProgress:(void (^)(PBDeviceCheckStepResult *))progress
                            completion:(void (^)(NSArray<PBDeviceCheckStepResult *> *, NSError *))completion {
    NSMutableArray<PBDeviceCheckStepResult *> *allSteps = [NSMutableArray array];
    
    void (^emit)(NSString *, NSString *, BOOL) = ^(NSString *title, NSString *detail, BOOL success) {
        PBDeviceCheckStepResult *result = [[PBDeviceCheckStepResult alloc] init];
        result.stepTitle = title;
        result.stepDetail = detail;
        result.success = success;
        [allSteps addObject:result];
        if (progress) {
            progress(result);
        }
    };
    
    // ─────────────────────────────────────────────────────────────
    // Step 1：客户端 — DCDevice.currentDevice.generateToken(...)
    // ─────────────────────────────────────────────────────────────
    if (@available(iOS 11.0, *)) {
        DCDevice *device = DCDevice.currentDevice;
        if (!device.isSupported) {
            emit(@"Step 1 · 客户端生成 Token",
                 @"当前设备/环境不支持 DeviceCheck（模拟器通常不支持，请用真机测试）",
                 NO);
            if (completion) {
                completion(allSteps.copy, [self errorWithMessage:@"DeviceCheck 不可用"]);
            }
            return;
        }
        
        [device generateTokenWithCompletionHandler:^(NSData * _Nullable token, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error || token.length == 0) {
                    emit(@"Step 1 · 客户端生成 Token",
                         error.localizedDescription ?: @"Token 为空",
                         NO);
                    if (completion) {
                        completion(allSteps.copy, error ?: [self errorWithMessage:@"Token 生成失败"]);
                    }
                    return;
                }
                
                NSString *tokenBase64 = [token base64EncodedStringWithOptions:0];
                emit(@"Step 1 · 客户端生成 Token",
                     [NSString stringWithFormat:
                      @"调用 DCDevice.currentDevice.generateToken 成功。\n"
                      @"Token 是一次性的、短时效凭证，每次调用都不同：\n%@",
                      tokenBase64],
                     YES);
                
                // Step 2 & 3 & 4：服务端流程（本地模拟，演示真实业务应如何实现）
                [self simulateServerWorkflowWithToken:token
                                             tokenBase64:tokenBase64
                                              emitStep:emit
                                            completion:^{
                    if (completion) {
                        completion(allSteps.copy, nil);
                    }
                }];
            });
        }];
        return;
    }
    
    emit(@"Step 1 · 客户端生成 Token", @"iOS 11 以下不支持 DeviceCheck", NO);
    if (completion) {
        completion(allSteps.copy, [self errorWithMessage:@"系统版本过低"]);
    }
}

#pragma mark - 服务端流程模拟

/**
 Step 2 ~ 4 在真实项目中发生在「开发者服务器」上，App 不直接访问 Apple。
 
 服务端需配置：
 1. 在 Apple Developer 后台创建 DeviceCheck 私钥（.p8）
 2. 用私钥签发 JWT（ES256），作为请求 Apple API 的 Authorization
 3. 调用 Apple DeviceCheck REST API
 
 生产环境：https://api.devicecheck.apple.com/v1/validate_device_token
 开发环境：https://api.development.devicecheck.apple.com/v1/validate_device_token
 
 常用接口：
 - validate_device_token  校验 Token 是否有效
 - query_two_bits         查询该设备两个 bit 的当前值（0 或 1）
 - update_two_bits        更新该设备两个 bit（每台设备每 bit 只能写一次永久值）
 
 重点：Apple 不会返回 UDID / IDFA 等设备标识，只通过 bit 状态间接表达「是不是同一台设备」。
 */
+ (void)simulateServerWorkflowWithToken:(NSData *)token
                            tokenBase64:(NSString *)tokenBase64
                               emitStep:(void (^)(NSString *, NSString *, BOOL))emit
                             completion:(void (^)(void))completion {
    // Step 2：App 将 Token 上传至开发者服务器
    emit(@"Step 2 · App → 开发者服务器",
         [NSString stringWithFormat:
          @"客户端 POST 自己的业务接口，例如：\n"
          @"POST /api/devicecheck/verify\n"
          @"Body: { \"device_token\": \"%@\" }\n\n"
          @"⚠️ Token 不要在前端自行解析，必须交给服务端处理。",
          [self truncatedToken:tokenBase64 maxLength:48]],
         YES);
    
    // 模拟网络耗时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Step 3：开发者服务器 → Apple DeviceCheck Server
        emit(@"Step 3 · 开发者服务器 → Apple",
             @"服务端携带 JWT，请求 Apple DeviceCheck API：\n"
             @"POST https://api.devicecheck.apple.com/v1/validate_device_token\n"
             @"Header: Authorization: Bearer <JWT>\n"
             @"Body: {\n"
             @"  \"device_token\": \"<客户端传来的 Token>\",\n"
             @"  \"transaction_id\": \"<UUID>\",\n"
             @"  \"timestamp\": <毫秒时间戳>\n"
             @"}\n\n"
             @"校验通过后，可继续调用 query_two_bits / update_two_bits。",
             YES);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // Step 4：Apple 判断结果（示例用本地逻辑演示 bit 读写含义）
            [self simulateAppleBitQueryWithToken:token emitStep:emit];
            if (completion) {
                completion();
            }
        });
    });
}

/**
 模拟 query_two_bits / update_two_bits 的业务含义。
 真实环境中这两个接口由服务端调用，返回示例：
 { "bit0": false, "bit1": true, "last_update_time": "2024-01-01T00:00:00Z" }
 */
+ (void)simulateAppleBitQueryWithToken:(NSData *)token
                              emitStep:(void (^)(NSString *, NSString *, BOOL))emit {
    // 用 Token 哈希模拟「同一设备 bit 状态稳定」的特性（仅演示，非 Apple 真实算法）
    uint64_t hash = 0;
    const uint8_t *bytes = token.bytes;
    for (NSUInteger i = 0; i < token.length; i++) {
        hash = hash * 31 + bytes[i];
    }
    BOOL bit0 = (hash & 1) == 0;
    BOOL bit1 = (hash & 2) == 0;
    
    emit(@"Step 4 · Apple 判断「是否同一台设备」",
         [NSString stringWithFormat:
          @"Apple 不会把设备 ID 返回给开发者，只返回 bit 状态：\n"
          @"  bit0 = %@（例如：是否领过新用户礼包）\n"
          @"  bit1 = %@（例如：是否在风控黑名单）\n\n"
          @"同一台设备多次 query_two_bits，bit 值保持一致 → 可判断「是同一台设备」。\n"
          @"不同设备 bit 组合独立，开发者无法反查硬件标识。\n\n"
          @"update_two_bits 示例：首次注册时将 bit0 置为 true，防止卸载重装重复领取。",
          bit0 ? @"true" : @"false",
          bit1 ? @"true" : @"false"],
         YES);
}

#pragma mark - Utils

+ (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"PBDeviceCheckExample"
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
}

+ (NSString *)truncatedToken:(NSString *)token maxLength:(NSUInteger)maxLength {
    if (token.length <= maxLength) {
        return token;
    }
    return [NSString stringWithFormat:@"%@...", [token substringToIndex:maxLength]];
}

@end
