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
    
    NSString *urlStr = @"https://mbd.baidu.com/suggest?empty_field=10001&ctl=his&action=list&cfrom=1005640h&from=1005640h&fv=11.18.0.0&network=1_0&osbranch=i3&osname=baiduboxapp&puid=_u2Kt_OQv8SlmqqqB&service=bdbox&sid=5928_9608-3079_8164-1820_4395-5682_8786-5583_8566-5534_8296-5748_8984-2361_6009-97_1-2371_6034-5601_8529-2638_6758-5649_8688-5463_8044-5950_9760-5481_8115-3024_7985-2360_6008-5907_9533-2864_7471-5882_9422-2779_7214-5897_9484-5957_9812-5644_8666-2866_7475-5483_8131-2865_7473-2363_6013&st=0&ua=828_1792_iphone_4.17.0.5_0&uid=4C8D97B2A6BAC77F7D221FBD60F1FEBDC82EC6151OHMDKBQQCM&ut=iPhone11%2C8_12.1.2&zid=d46DE-y4sxPNFtFGFaa15u-ycaQ2ujDprib0lUUMQGs2MjhjJN-4M9Bzf9BLP98qpIs0FMnrmus3YsmBAYYtnAQ";
    
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
