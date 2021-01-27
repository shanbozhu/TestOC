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
    NSString *urlStr = @"https://mbd.baidu.com/icomment/v1/comment/list?appname=baiduboxlite&cfrom=1005640h&from=1005640h&fv=12.1.0.0&matrixstyle=0&network=1_0&sid=6566_12070-6565_12068-5748_8984-5583_8566-5682_8784-5534_8296-7254_14771-6973_13646-5957_9811-5601_8529-5987_9960-6197_10730-6170_10622-5463_8044-3000127_1-159_4-5558_8367-5644_8666-6110_10431-5483_8131-6358_11300-6375_11363&st=0&ua=828_1792_iphone_5.1.1.10_0&uid=45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH&ut=iPhone11%2C8_12.1.2&zid=Nz1vfc_o7oN3ci-TIwM1lwW9-GqQg2jHJyLNp9nVbRIHhgbIVW4OVnCeiRhpIqEjYXcbGrU5UQymp2JPdo_EmqA&sdkversion=1.1.2";
    
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
        [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16C104 SP-engine/2.24.0 matrixstyle/0 info baiduboxapp/5.1.1.10 (Baidu; P2 12.1.2)" forHTTPHeaderField:@"User-Agent"];
        [manager.requestSerializer setValue:@"BAIDUCUID=gaS98giPH8_fu28xli2yu0PjHt_RaS8V_O2Ca0aMH8_ui2tY0O2NtYi2QP0z8WPCbWHmA; MBD_AT=1611037261; __yjs_duid=1_16ef112911fea7f8f85861dd4cd865d61611037267886; BDUSS=o4dG9PbFUyaHJ6YmlJUXFUV1htNlNnQVBvWVV1TkJZcXlocWYwRlEwWVd6VmhmSVFBQUFBJCQAAAAAAAAAAAEAAAAKxaCGusPA1tTDztIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABZAMV8WQDFfU0; BAIDUID=5C8D78D64E6848E8E66D846DD5DFFE60:FG=1; fnizebra_b=P0lhrcN53vdMUS%2F6i6Jqke1DYnu1Bk7BKyn22Lr1OiSJcdkcuIE5QRexh80u3Q0CHAwYzANIhkgioe4D%2FK5Sa7%2BwWEa0CsRrSUcPM4pO%2FvjxvQAdf9qVcn5mRMjr6xQqsgdHPQGIyAFdR6CUMsb5axYXkySjX0%2BtBF7OsuEKruY%3D; SP_FW_VER=3.240.16; iadlist=49153; fontsize=1.10; H_WISE_SIDS=107314_110086_114551_127969_144966_154214_156286_156306_161278_162187_162203_162898_163115_163274_163390_163581_163808_163933_164043_164110_164164_164214_164216_164296_164692_164865_164880_164941_164992_165071_165135_165144_165327_165345_165591_165737_166055_166147_166180_166184_166255_166597_166599_166825_166987_167303_167388_167537_167571_167744_167771_167781_167926_167980_168034_168073_168215_168402; WISE_HIS_PM=1; BCLID=9140690592728723096; BDSFRCVID=JYKOJeCinR3Chr6eBYNMUON2YgKX8jRTH60oY2ODlwB_I7JoXeN5EG0P8x8g0KubrAb4ogKK0eOTHkCF_2uxOjjg8UtVJeC6EG0Ptf8g0f5; H_BDCLCKID_SF=tbCD_KK5JKD3HtJxKITHKb8jbeT22-usWH5i2hcH0bT_VCOJMbK-bfD4X4cPWMCHyCvihIn_Lfb1MCJvWj5cQ-AWLRnAtMTyyITw_l5TtUtWJKnTDMRh-RDF-GOyKMnitIT9-pno0hQrh459XP68bTkA5bjZKxtq3mkjbPbDfn02eCKu-n5jHjoWjajP; ST=0; BAIDULOC=13538033.981942_3634594.7065378_1000_289_1611659203826; ab_sr=1.0.0_MDg2OTViODUwYzI5ZDIwYmRjMmYyNjRhMmQyMWU0Y2JlMTRlOThhNDc5MzUyN2NjYjkzYzE4ZmYzYzQ1YjE3NmIwN2FiNTcxMDZjNjMwZTNiYTExMzhiNzQwMmY5ZmY3; x-logic-no=2" forHTTPHeaderField:@"Cookie"];
        [manager.requestSerializer setValue:@"https://m.baidu.com/s?tn=zbios&pu=sz%401320_480%2Ccuid%4045D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH%2Ccua%40828_1792_iphone_1.0.0.10_0%2Ccut%40iPhone11%2C8_12.1.2%2Cosname%40baiduboxapp%2Cosbranch%40i7%2Cctv%401%2Ccfrom%401005640h%2Ccsrc%40bdbox_tserch_txt%2Ccud%40REZCMkE2QjgtNkMzNy00MUEyLTgzRTEtQzMwNzk3RjhFQTRF&bd_page_type=1&word=%E5%BE%AE%E4%BF%A1%E5%B0%86%E6%8E%A8%E5%87%BA%E8%87%AA%E6%9C%89%E8%BE%93%E5%85%A5%E6%B3%95&sa=tkhr_3&ss=001001&network=1_0&from=1005640h&ant_ct=9%2BITzc9iee5%2F3Th%2BMIiUBqEXMBYcqM9RpZIkZRns%2Bxa8lKlxRUWJgmddGTCRGtet&rsv_sug4=8959&rsv_pq=16111291210279897629&oq=%E6%8B%9C%E7%99%BB%E5%90%AF%E7%A8%8B%E5%B0%B1%E8%81%8C%E5%91%8A%E5%88%AB%E6%B3%AA%E6%B4%92%E5%AE%B6%E4%B9%A1" forHTTPHeaderField:@"Referer"];
        
        // 请求体
        NSMutableDictionary *paras = [NSMutableDictionary dictionary];
        [paras setValue:@"1088000038593190" forKey:@"topic_id"];
        [paras setValue:@"video" forKey:@"source"];
        [paras setValue:@"9" forKey:@"order"];
        [paras setValue:@"video" forKey:@"thread_type"];
        [paras setValue:@"0" forKey:@"start"];
        [paras setValue:@"sv_8576735144960951200" forKey:@"nid"];
        [paras setValue:@"20" forKey:@"num"];
        NSMutableDictionary *extdata = [NSMutableDictionary dictionary];
        [extdata setValue:@"feed" forKey:@"origin"];
        [extdata setValue:@"" forKey:@"s_session"];
        [paras setValue:extdata forKey:@"extdata"];
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
        // 默认添加请求头: "Content-Type": "application/x-www-form-urlencoded"
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 直接返回jsonStr, 以二进制形式
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSMutableDictionary *paras = [self requestHeaderAndBody:manager];
        [paras setValue:@"3.x" forKey:@"AFNetworking"];
        
        [manager POST:urlStr parameters:paras success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            [self processDataWithResponseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
        }];
    }
    
    {
        // AFNetworking 3.x
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 默认添加请求头: "Content-Type": "application/json"
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        // 直接返回jsonDict
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSMutableDictionary *paras = [self requestHeaderAndBody:manager];
        [paras setValue:@"3.x" forKey:@"AFNetworking"];
        
        [manager POST:urlStr parameters:paras success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            [self processDataWithResponseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
        }];
    }
}

- (NSMutableDictionary *)requestHeaderAndBody:(AFHTTPSessionManager *)manager {
    // 请求头
    [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16C104 SP-engine/2.24.0 matrixstyle/0 info baiduboxapp/5.1.1.10 (Baidu; P2 12.1.2)" forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:@"BAIDUCUID=gaS98giPH8_fu28xli2yu0PjHt_RaS8V_O2Ca0aMH8_ui2tY0O2NtYi2QP0z8WPCbWHmA; MBD_AT=1611037261; __yjs_duid=1_16ef112911fea7f8f85861dd4cd865d61611037267886; BDUSS=o4dG9PbFUyaHJ6YmlJUXFUV1htNlNnQVBvWVV1TkJZcXlocWYwRlEwWVd6VmhmSVFBQUFBJCQAAAAAAAAAAAEAAAAKxaCGusPA1tTDztIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABZAMV8WQDFfU0; BAIDUID=5C8D78D64E6848E8E66D846DD5DFFE60:FG=1; fnizebra_b=P0lhrcN53vdMUS%2F6i6Jqke1DYnu1Bk7BKyn22Lr1OiSJcdkcuIE5QRexh80u3Q0CHAwYzANIhkgioe4D%2FK5Sa7%2BwWEa0CsRrSUcPM4pO%2FvjxvQAdf9qVcn5mRMjr6xQqsgdHPQGIyAFdR6CUMsb5axYXkySjX0%2BtBF7OsuEKruY%3D; SP_FW_VER=3.240.16; iadlist=49153; fontsize=1.10; H_WISE_SIDS=107314_110086_114551_127969_144966_154214_156286_156306_161278_162187_162203_162898_163115_163274_163390_163581_163808_163933_164043_164110_164164_164214_164216_164296_164692_164865_164880_164941_164992_165071_165135_165144_165327_165345_165591_165737_166055_166147_166180_166184_166255_166597_166599_166825_166987_167303_167388_167537_167571_167744_167771_167781_167926_167980_168034_168073_168215_168402; WISE_HIS_PM=1; BCLID=9140690592728723096; BDSFRCVID=JYKOJeCinR3Chr6eBYNMUON2YgKX8jRTH60oY2ODlwB_I7JoXeN5EG0P8x8g0KubrAb4ogKK0eOTHkCF_2uxOjjg8UtVJeC6EG0Ptf8g0f5; H_BDCLCKID_SF=tbCD_KK5JKD3HtJxKITHKb8jbeT22-usWH5i2hcH0bT_VCOJMbK-bfD4X4cPWMCHyCvihIn_Lfb1MCJvWj5cQ-AWLRnAtMTyyITw_l5TtUtWJKnTDMRh-RDF-GOyKMnitIT9-pno0hQrh459XP68bTkA5bjZKxtq3mkjbPbDfn02eCKu-n5jHjoWjajP; ST=0; BAIDULOC=13538033.981942_3634594.7065378_1000_289_1611659203826; ab_sr=1.0.0_MDg2OTViODUwYzI5ZDIwYmRjMmYyNjRhMmQyMWU0Y2JlMTRlOThhNDc5MzUyN2NjYjkzYzE4ZmYzYzQ1YjE3NmIwN2FiNTcxMDZjNjMwZTNiYTExMzhiNzQwMmY5ZmY3; x-logic-no=2" forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:@"https://m.baidu.com/s?tn=zbios&pu=sz%401320_480%2Ccuid%4045D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH%2Ccua%40828_1792_iphone_1.0.0.10_0%2Ccut%40iPhone11%2C8_12.1.2%2Cosname%40baiduboxapp%2Cosbranch%40i7%2Cctv%401%2Ccfrom%401005640h%2Ccsrc%40bdbox_tserch_txt%2Ccud%40REZCMkE2QjgtNkMzNy00MUEyLTgzRTEtQzMwNzk3RjhFQTRF&bd_page_type=1&word=%E5%BE%AE%E4%BF%A1%E5%B0%86%E6%8E%A8%E5%87%BA%E8%87%AA%E6%9C%89%E8%BE%93%E5%85%A5%E6%B3%95&sa=tkhr_3&ss=001001&network=1_0&from=1005640h&ant_ct=9%2BITzc9iee5%2F3Th%2BMIiUBqEXMBYcqM9RpZIkZRns%2Bxa8lKlxRUWJgmddGTCRGtet&rsv_sug4=8959&rsv_pq=16111291210279897629&oq=%E6%8B%9C%E7%99%BB%E5%90%AF%E7%A8%8B%E5%B0%B1%E8%81%8C%E5%91%8A%E5%88%AB%E6%B3%AA%E6%B4%92%E5%AE%B6%E4%B9%A1" forHTTPHeaderField:@"Referer"];
    
    // 请求体
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    [paras setValue:@"1088000038593190" forKey:@"topic_id"];
    [paras setValue:@"video" forKey:@"source"];
    [paras setValue:@"9" forKey:@"order"];
    [paras setValue:@"video" forKey:@"thread_type"];
    [paras setValue:@"0" forKey:@"start"];
    [paras setValue:@"sv_8576735144960951200" forKey:@"nid"];
    [paras setValue:@"20" forKey:@"num"];
    NSMutableDictionary *extdata = [NSMutableDictionary dictionary];
    [extdata setValue:@"feed" forKey:@"origin"];
    [extdata setValue:@"" forKey:@"s_session"];
    [paras setValue:extdata forKey:@"extdata"];
    
    return paras;
}

- (void)processDataWithResponseObject:(id)responseObject {
    if ([responseObject isKindOfClass:[NSData class]]) {
        // jsonDict
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"jsonDict = %@", jsonDict);
        
        // jsonStr
        NSString *jsonStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"jsonStr = %@", jsonStr);
    }
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        // jsonDict
        NSDictionary *jsonDict = responseObject;
        NSLog(@"jsonDict = %@", jsonDict);
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:nil];
        
        // jsonStr
        NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"jsonStr = %@", jsonStr);
    }
}

@end
