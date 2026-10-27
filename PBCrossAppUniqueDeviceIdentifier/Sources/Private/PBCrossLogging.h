//
//  PBCrossLogging.h
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>

/// 仅当 configuration.loggingEnabled 为 YES 时输出调试日志。
/// 不直接使用 NSLog，避免宿主工程重定义 NSLog 导致格式化异常。
#ifndef PBCrossLog
#define PBCrossLog(configuration_, fmt, ...) \
    do { \
        if ((configuration_).loggingEnabled) { \
            NSString *pb_log_message_ = [NSString stringWithFormat:(fmt), ##__VA_ARGS__]; \
            fprintf(stderr, "[PBCrossAppUniqueDeviceIdentifier] %s\n", pb_log_message_.UTF8String); \
        } \
    } while (0)
#endif
