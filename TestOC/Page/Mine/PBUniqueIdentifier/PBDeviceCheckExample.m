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
 - query_two_bits         查询该开发者在该设备上设置的两个 bit（0 或 1）
 - update_two_bits        更新该开发者在该设备上的两个 bit（每台设备每 bit 通常只能写一次）
 
 重点：Apple 不会返回 UDID / IDFA 等设备标识。bit 是开发者定义的风控状态，
 不是设备身份；相同 bit 不能证明是同一台设备。
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
            // Step 4：展示 Apple 返回的两个 bit（本地固定模拟值，非真实 Apple 数据）
            [self simulateAppleBitQueryWithEmitStep:emit];
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
 
 这里使用固定模拟值，避免用一次性 Token 推导出“每次不同”的 bit，
 也避免让人误以为 bit 可以作为设备 ID。
 */
+ (void)simulateAppleBitQueryWithEmitStep:(void (^)(NSString *, NSString *, BOOL))emit {
    BOOL bit0 = YES;
    BOOL bit1 = NO;
    
    emit(@"Step 4 · Apple 返回的风控 bit（模拟）",
         [NSString stringWithFormat:
          @"Apple 不会把设备 ID 返回给开发者，只返回开发者设置的两个 bit：\n"
          @"  bit0 = %@（示例：是否已标记领取过新用户礼包）\n"
          @"  bit1 = %@（示例：是否命中风控黑名单）\n\n"
          @"以上是固定模拟值；真实值由服务端 query_two_bits 查询。\n"
          @"注意：bit 只有 4 种组合，相同 bit 不能证明是同一台设备；\n"
          @"不同设备可能得到相同组合，同一设备也可能因业务状态变化。\n"
          @"DeviceCheck 只能作为风控信号，不能当作设备唯一标识。\n\n"
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
