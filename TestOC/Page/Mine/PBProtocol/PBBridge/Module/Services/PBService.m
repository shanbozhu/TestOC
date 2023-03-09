//
//  PBService.m
//  TestOC
//
//  Created by shanbo on 2023/3/7.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBService.h"
#import "PBServiceBridge.h"

// 参考文档:https://www.jianshu.com/p/036f502a2b15/
// 调用顺序: +load -> __attribute__((constructor)) -> main -> +initialize
// 如果在 +load或__attribute__((constructor)) 中使用了该类,那么该类的 +initialize 会早于 main 调用

__attribute__((constructor))
static void registerClassService(void) {
    NSLog(@"2 - __attribute__((constructor))");
    // 注册服务类对象
    [PBServiceBridge registerClassService:[PBService class]
                                 protocol:@protocol(PBServiceProtocol)];
}

@implementation PBService

+ (void)initialize {
    if (self == [PBService class]) {
        NSLog(@"initialize, 第一次使用该类的时候调用");
    }
}

+ (void)load {
    NSLog(@"1 - load");
}

+ (void)doSomething {
    NSLog(@"PBService +doSomething");
}

#pragma mark -

- (void)doSomething {
    NSLog(@"PBService -doSomething");
}

@end
