//
//  PBAFNetworkingZeroController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAFNetworkingZeroController.h"
#import <AFNetworking/AFNetworking.h>

@interface PBAFNetworkingZeroController ()

@end

@implementation PBAFNetworkingZeroController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlStr = @"https://mapi.damai.cn/proj/search/HotWord.aspx?a=hello&b=world";
    
    {
        NSURL *url = [NSURL URLWithString:urlStr];
        NSLog(@"url.scheme = %@, url.host = %@, url.port = %@, url.path = %@, url.query = %@", url.scheme, url.host, url.port, url.path, url.query);
    }
    
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    [paras setValue:@"852" forKey:@"cityid"];
    [paras setValue:@"3" forKey:@"osType"];
    [paras setValue:@"10099" forKey:@"source"];
    [paras setValue:@"60103" forKey:@"version"];
    
    {
        // AFNetworking 2.x
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];

        [manager POST:urlStr parameters:paras success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [self processDataWithResponseObject:responseObject];
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
        }];
    }
    
    {
        // AFNetworking 3.x
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager POST:urlStr parameters:paras success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            [self processDataWithResponseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
        }];
    }
}

- (void)processDataWithResponseObject:(id)responseObject {
    // jsonDict
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonDict = %@", jsonDict);
    
    // jsonStr
    NSString *jsonStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSLog(@"jsonStr = %@", jsonStr);
    
    // jsonStr
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr1 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"jsonStr1 = %@", jsonStr1);
}

@end
