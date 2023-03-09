//
//  PBProtocolController.m
//  TestOC
//
//  Created by shanbo on 2023/3/6.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBProtocolController.h"
#import "PBService.h"
#import "PBServiceBridge.h"

@interface PBProtocolController ()

@property (nonatomic, strong) PBService *service;

@end

@implementation PBProtocolController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 参考文档:
    // iOS：Protocol详解 https://blog.csdn.net/a18339063397/article/details/120891093
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(100, 200, 50, 50);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 注册服务对象
    PBService *service = [[PBService alloc] init];
    self.service = service;
    [PBServiceBridge registerService:service protocol:@protocol(PBServiceProtocol)];
}

- (void)btnClick:(UIButton *)btn {
    // 分发服务对象
    NSArray *services = [PBServiceBridge servicesForProtocol:@protocol(PBServiceProtocol)];
    [services enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(doSomething)]) {
            [obj doSomething];
        }
    }];
    
    // 分发服务类对象
    Class<PBServiceProtocol> aClass = [PBServiceBridge classServiceForProtocol:@protocol(PBServiceProtocol)];
    if ([aClass respondsToSelector:@selector(doSomething)]) {
        [aClass doSomething];
    }
}

@end
