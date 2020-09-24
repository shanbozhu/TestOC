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
    
    // 路径、参数
    NSString *urlStr = @"https://mbd.baidu.com/suggest?empty_field=10001&ctl=his&action=list&cfrom=1005640h&from=1005640h&fv=11.18.0.0&network=1_0&osbranch=i3&osname=baiduboxapp&puid=_u2Kt_OQv8SlmqqqB&service=bdbox&sid=5928_9608-3079_8164-1820_4395-5682_8786-5583_8566-5534_8296-5748_8984-2361_6009-97_1-2371_6034-5601_8529-2638_6758-5649_8688-5463_8044-5950_9760-5481_8115-3024_7985-2360_6008-5907_9533-2864_7471-5882_9422-2779_7214-5897_9484-5957_9812-5644_8666-2866_7475-5483_8131-2865_7473-2363_6013&st=0&ua=828_1792_iphone_4.17.0.5_0&uid=4C8D97B2A6BAC77F7D221FBD60F1FEBDC82EC6151OHMDKBQQCM&ut=iPhone11%2C8_12.1.2&zid=d46DE-y4sxPNFtFGFaa15u-ycaQ2ujDprib0lUUMQGs2MjhjJN-4M9Bzf9BLP98qpIs0FMnrmus3YsmBAYYtnAQ";
    
    {
        NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"url.scheme = %@, url.host = %@, url.port = %@, url.path = %@, url.query = %@", url.scheme, url.host, url.port, url.path, url.query);
    }
    
    {
        // AFNetworking 2.x
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        // 请求头
        [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16C104 SP-engine/2.14.0 info baiduboxapp/4.18.0.0 (Baidu; P2 12.1.2)" forHTTPHeaderField:@"User-Agent"];
        [manager.requestSerializer setValue:@"WISE_HIS_PM=1; BAIDULOC=13538028.284849_3634591.0306334_1000_289_1592470077867; x-logic-no=2; BDUSS=H5ISG1vV0JVakY5VmpEU2FzdS1JfkRmSWFOV0tWcHNKUDE2a1pFbkNoaXhzUkpmSVFBQUFBJCQAAAAAAAAAAAEAAAAKxaCGusPA1tTDztIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALEk616xJOtea; GID=G1T1O7NNLUWEWYJKQMPMM3FDT4XT7HUQLC; iadlist=49153; ST=0; BA_HECTOR=6ojjnk; H_WISE_SIDS=148078_147888_148643_146653_148320_138163_147276_142018_147279_148868_147893_148434_148663_148823_148523_148724_127969_147547_147638_149313_144966_145607_149535_147847_148346_146732_147614_148230_144658_147682_148754_146395_147990_146958_149247_147527_138426_149439_148186_149278_147595_148050_146575_148750_146851_147355_110086; passtheme=light; fontsize=1.00; BDPASSGATE=IlPT2AEptyoA_yiU4VKI3kIN8efRSvCBAevJSDR6QlStfCaWmhH3BrUvWz0HSieXBDP6wZTXt0Nmlj8KXlVXa_EqnBsZolpManS5xNSCgsTtPsx17Qok_QCXGCE2sA8PbRhL-3MEF3VDMlMCpubxgewmcOqsxQNHafmI5EDCmMrs1TCG17r6nmatXIpfRHveYOeNwujDnH-qP-HtTgbNGVbzhXMKWIIL7tyKiOMmPOD5rkoXGurSRvAa1Fz5BJV2BxCyGwC78qSo065vvnUnVEI-nUOY7tC; BAIDUCUID=g8-3ajarHi0LaSuSlu2-u_8Z2i_B8HuK_aSl8l87Ha00PvuZ0uv1igteQOlztSM3w6wmA; userDeviceId=Jsm64G1592394541; BDORZ=AE84CDB3A529C0F8A2B9DCDD1D18B695; MBD_AT=1592367146; BIDUPSID=38417D431F526BDC7F13BD5416319D69; IMG_WH=414_718; BAIDUID=38417D431F526BDC7F13BD5416319D69:FG=1" forHTTPHeaderField:@"Cookie"];
        
        // 请求体
        NSMutableDictionary *paras = [NSMutableDictionary dictionary];
        [paras setValue:@"852" forKey:@"cityid"];
        [paras setValue:@"3" forKey:@"osType"];
        [paras setValue:@"10099" forKey:@"source"];
        [paras setValue:@"60103" forKey:@"version"];
        [paras setValue:@"2.x" forKey:@"AFNetworking"];

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
        
        // 请求头
        [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16C104 SP-engine/2.14.0 info baiduboxapp/4.18.0.0 (Baidu; P2 12.1.2)" forHTTPHeaderField:@"User-Agent"];
        [manager.requestSerializer setValue:@"WISE_HIS_PM=1; BAIDULOC=13538028.284849_3634591.0306334_1000_289_1592470077867; x-logic-no=2; BDUSS=H5ISG1vV0JVakY5VmpEU2FzdS1JfkRmSWFOV0tWcHNKUDE2a1pFbkNoaXhzUkpmSVFBQUFBJCQAAAAAAAAAAAEAAAAKxaCGusPA1tTDztIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALEk616xJOtea; GID=G1T1O7NNLUWEWYJKQMPMM3FDT4XT7HUQLC; iadlist=49153; ST=0; BA_HECTOR=6ojjnk; H_WISE_SIDS=148078_147888_148643_146653_148320_138163_147276_142018_147279_148868_147893_148434_148663_148823_148523_148724_127969_147547_147638_149313_144966_145607_149535_147847_148346_146732_147614_148230_144658_147682_148754_146395_147990_146958_149247_147527_138426_149439_148186_149278_147595_148050_146575_148750_146851_147355_110086; passtheme=light; fontsize=1.00; BDPASSGATE=IlPT2AEptyoA_yiU4VKI3kIN8efRSvCBAevJSDR6QlStfCaWmhH3BrUvWz0HSieXBDP6wZTXt0Nmlj8KXlVXa_EqnBsZolpManS5xNSCgsTtPsx17Qok_QCXGCE2sA8PbRhL-3MEF3VDMlMCpubxgewmcOqsxQNHafmI5EDCmMrs1TCG17r6nmatXIpfRHveYOeNwujDnH-qP-HtTgbNGVbzhXMKWIIL7tyKiOMmPOD5rkoXGurSRvAa1Fz5BJV2BxCyGwC78qSo065vvnUnVEI-nUOY7tC; BAIDUCUID=g8-3ajarHi0LaSuSlu2-u_8Z2i_B8HuK_aSl8l87Ha00PvuZ0uv1igteQOlztSM3w6wmA; userDeviceId=Jsm64G1592394541; BDORZ=AE84CDB3A529C0F8A2B9DCDD1D18B695; MBD_AT=1592367146; BIDUPSID=38417D431F526BDC7F13BD5416319D69; IMG_WH=414_718; BAIDUID=38417D431F526BDC7F13BD5416319D69:FG=1" forHTTPHeaderField:@"Cookie"];
        
        // 请求体
        NSMutableDictionary *paras = [NSMutableDictionary dictionary];
        [paras setValue:@"852" forKey:@"cityid"];
        [paras setValue:@"3" forKey:@"osType"];
        [paras setValue:@"10099" forKey:@"source"];
        [paras setValue:@"60103" forKey:@"version"];
        [paras setValue:@"3.x" forKey:@"AFNetworking"];
        
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
}

@end
