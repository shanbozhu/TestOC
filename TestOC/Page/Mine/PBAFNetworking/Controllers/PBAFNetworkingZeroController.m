//
//  PBAFNetworkingZeroController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAFNetworkingZeroController.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+BBAURL.h"

@interface PBAFNetworkingZeroController ()

@end

@implementation PBAFNetworkingZeroController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求路径、请求参数
    NSString *urlStr = @"https://mbd.baidu.com/icomment/v1/comment/rlist?appname=baiduboxlite&cfrom=1005640h&ds_lv=4&ds_stc=0.7740&from=1005640h&fv=13.30.0.10&matrixstyle=0&mps=154326807&mpv=1&network=1_0&sid=34836_3-8319_19556-56196_2-8313_19529-56785_2-56115_2-34064_2-35158_1-5760_9013-34999_8-35148_1-35262_2-107862_3-32205_2-56359_4-55371_1-35215_2-5280_7494-56512_4-9619_2-8321_19560-33923_6-9451_2-9618_2-8083_18570-5644_8666-56430_2-35223_1-5153_7043-34731_2-35072_2-56076_3&st=0&ua=828_1792_iphone_6.1.0.3_0&uid=45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH&zid=Nz1vfc_o7oN3ci-TIwM1lwW9-GqQg2jHJyLNp9nVbRIFAsQJxD06HMqQTcbu6Y9x0StTFnWsNpHkiJhkxPtHb6Q&sdkversion=1.1.2";
    
    {
        NSLog(@"[urlStr bdp_encodeURIComponent] = %@", [urlStr bdp_encodeURIComponent]);
        NSLog(@"[urlStr bdp_percentEncoding] = %@", [urlStr bdp_percentEncoding]);
        NSLog(@"[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] = %@", [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
        
        NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        /**
         https网络请求
         方式：GET（没有请求体）、POST
         请求：域名（host）、端口号（port）、请求路径（path）、请求参数（query）、请求头、请求体
         响应：响应头、响应体
         */
        // 协议（scheme）：https://
        // 域名（host）：mbd.baidu.com。子域名：mbd、二级域名：baidu、顶级域名：com
        // 端口（port）：443
        // 路径（path）：/icomment/v1/comment/rlist
        // 参数（query）：appname=baiduboxlite&cfrom=1005640h&ds_lv=4&ds_stc=0.7740&from=1005640h&fv=13.30.0.10&matrixstyle=0&mps=154326807&mpv=1&network=1_0&sid=34836_3-8319_19556-56196_2-8313_19529-56785_2-56115_2-34064_2-35158_1-5760_9013-34999_8-35148_1-35262_2-107862_3-32205_2-56359_4-55371_1-35215_2-5280_7494-56512_4-9619_2-8321_19560-33923_6-9451_2-9618_2-8083_18570-5644_8666-56430_2-35223_1-5153_7043-34731_2-35072_2-56076_3&st=0&ua=828_1792_iphone_6.1.0.3_0&uid=45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH&zid=Nz1vfc_o7oN3ci-TIwM1lwW9-GqQg2jHJyLNp9nVbRIFAsQJxD06HMqQTcbu6Y9x0StTFnWsNpHkiJhkxPtHb6Q&sdkversion=1.1.2
        NSLog(@"url.scheme = %@, url.host = %@, url.port = %@, url.path = %@, url.query = %@", url.scheme, url.host, url.port, url.path, url.query);
    }
    
    {
        // AFNetworking 2.x
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        // 添加请求头: "Content-Type": "application/x-www-form-urlencoded"
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 返回二进制
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES; // 是否允许CA不信任的证书通过
        policy.validatesDomainName = NO; // 是否验证主机名
        manager.securityPolicy = policy;
        
        NSMutableDictionary *params = [self requestHeaderAndBody:manager];
        [params setValue:@"2.x" forKey:@"AFNetworking"];
        
        // 请求方式
        [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [self processDataWithResponseObject:responseObject];
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
        }];
    }
    
    {
        // AFNetworking 3.x
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 添加请求头: "Content-Type": "application/x-www-form-urlencoded"
        // AFNetworking会将json字典转换为x-www-form-urlencoded格式
        // 转换的核心方法是AFNetworking里的`static NSString * AFQueryStringFromParameters(NSDictionary *parameters)`方法
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 返回二进制
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES; // 是否允许CA不信任的证书通过
        policy.validatesDomainName = NO; // 是否验证主机名
        manager.securityPolicy = policy;
        
        NSMutableDictionary *params = [self requestHeaderAndBody:manager];
        [params setValue:@"3.x" forKey:@"AFNetworking"];
        
        // 请求方式
        [manager POST:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            [self processDataWithResponseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
        }];
    }
    
    {
        // AFNetworking 3.x
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 添加请求头: "Content-Type": "application/json"
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        // 返回jsonDict
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES; // 是否允许CA不信任的证书通过
        policy.validatesDomainName = NO; // 是否验证主机名
        manager.securityPolicy = policy;
        
        NSMutableDictionary *params = [self requestHeaderAndBody:manager];
        [params setValue:@"3.x" forKey:@"AFNetworking"];
        
        // 请求方式
        [manager POST:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            [self processDataWithResponseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
        }];
    }
}

- (NSMutableDictionary *)requestHeaderAndBody:(id)ma {
    AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer = nil;
    if ([ma isKindOfClass:[AFHTTPRequestOperationManager class]]) {
        AFHTTPRequestOperationManager *manager = (AFHTTPRequestOperationManager *)ma;
        requestSerializer = manager.requestSerializer;
    } else if ([ma isKindOfClass:[AFHTTPSessionManager class]]) {
        AFHTTPSessionManager *manager = (AFHTTPSessionManager *)ma;
        requestSerializer = manager.requestSerializer;
    }
    
    // 请求头
    [requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16C104 SP-engine/2.24.0 matrixstyle/0 info baiduboxapp/5.1.1.10 (Baidu; P2 12.1.2)" forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"BAIDUCUID=gaS98giPH8_fu28xli2yu0PjHt_RaS8V_O2Ca0aMH8_ui2tY0O2NtYi2QP0z8WPCbWHmA; MBD_AT=1611037261; __yjs_duid=1_16ef112911fea7f8f85861dd4cd865d61611037267886; BDUSS=o4dG9PbFUyaHJ6YmlJUXFUV1htNlNnQVBvWVV1TkJZcXlocWYwRlEwWVd6VmhmSVFBQUFBJCQAAAAAAAAAAAEAAAAKxaCGusPA1tTDztIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABZAMV8WQDFfU0; BAIDUID=5C8D78D64E6848E8E66D846DD5DFFE60:FG=1; fnizebra_b=P0lhrcN53vdMUS%2F6i6Jqke1DYnu1Bk7BKyn22Lr1OiSJcdkcuIE5QRexh80u3Q0CHAwYzANIhkgioe4D%2FK5Sa7%2BwWEa0CsRrSUcPM4pO%2FvjxvQAdf9qVcn5mRMjr6xQqsgdHPQGIyAFdR6CUMsb5axYXkySjX0%2BtBF7OsuEKruY%3D; SP_FW_VER=3.240.16; iadlist=49153; fontsize=1.10; H_WISE_SIDS=107314_110086_114551_127969_144966_154214_156286_156306_161278_162187_162203_162898_163115_163274_163390_163581_163808_163933_164043_164110_164164_164214_164216_164296_164692_164865_164880_164941_164992_165071_165135_165144_165327_165345_165591_165737_166055_166147_166180_166184_166255_166597_166599_166825_166987_167303_167388_167537_167571_167744_167771_167781_167926_167980_168034_168073_168215_168402; WISE_HIS_PM=1; BCLID=9140690592728723096; BDSFRCVID=JYKOJeCinR3Chr6eBYNMUON2YgKX8jRTH60oY2ODlwB_I7JoXeN5EG0P8x8g0KubrAb4ogKK0eOTHkCF_2uxOjjg8UtVJeC6EG0Ptf8g0f5; H_BDCLCKID_SF=tbCD_KK5JKD3HtJxKITHKb8jbeT22-usWH5i2hcH0bT_VCOJMbK-bfD4X4cPWMCHyCvihIn_Lfb1MCJvWj5cQ-AWLRnAtMTyyITw_l5TtUtWJKnTDMRh-RDF-GOyKMnitIT9-pno0hQrh459XP68bTkA5bjZKxtq3mkjbPbDfn02eCKu-n5jHjoWjajP; ST=0; BAIDULOC=13538033.981942_3634594.7065378_1000_289_1611659203826; ab_sr=1.0.0_MDg2OTViODUwYzI5ZDIwYmRjMmYyNjRhMmQyMWU0Y2JlMTRlOThhNDc5MzUyN2NjYjkzYzE4ZmYzYzQ1YjE3NmIwN2FiNTcxMDZjNjMwZTNiYTExMzhiNzQwMmY5ZmY3; x-logic-no=2" forHTTPHeaderField:@"Cookie"];
    [requestSerializer setValue:@"https://m.baidu.com/s?tn=zbios&pu=sz%401320_480%2Ccuid%4045D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH%2Ccua%40828_1792_iphone_1.0.0.10_0%2Ccut%40iPhone11%2C8_12.1.2%2Cosname%40baiduboxapp%2Cosbranch%40i7%2Cctv%401%2Ccfrom%401005640h%2Ccsrc%40bdbox_tserch_txt%2Ccud%40REZCMkE2QjgtNkMzNy00MUEyLTgzRTEtQzMwNzk3RjhFQTRF&bd_page_type=1&word=%E5%BE%AE%E4%BF%A1%E5%B0%86%E6%8E%A8%E5%87%BA%E8%87%AA%E6%9C%89%E8%BE%93%E5%85%A5%E6%B3%95&sa=tkhr_3&ss=001001&network=1_0&from=1005640h&ant_ct=9%2BITzc9iee5%2F3Th%2BMIiUBqEXMBYcqM9RpZIkZRns%2Bxa8lKlxRUWJgmddGTCRGtet&rsv_sug4=8959&rsv_pq=16111291210279897629&oq=%E6%8B%9C%E7%99%BB%E5%90%AF%E7%A8%8B%E5%B0%B1%E8%81%8C%E5%91%8A%E5%88%AB%E6%B3%AA%E6%B4%92%E5%AE%B6%E4%B9%A1" forHTTPHeaderField:@"Referer"];
    
    // 请求体
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"1000000056224844" forKey:@"topic_id"];
    [params setValue:@"channel_video_landing" forKey:@"source"];
    [params setValue:@"0" forKey:@"start"];
    [params setValue:@"baidumedia" forKey:@"source_type"];
    [params setValue:@"1122518916369402407" forKey:@"reply_id"];
    [params setValue:@"38383331323433303437373531393733353736" forKey:@"request_id"];
    [params setValue:@"1762683039161549402" forKey:@"key"];
    [params setValue:@"20" forKey:@"num"];
    NSMutableDictionary *extdata = [NSMutableDictionary dictionary];
    [extdata setValue:@"feed" forKey:@"origin"];
    [extdata setValue:@"E18940390F8EC74785570C5BE86236F8" forKey:@"client_logid"];
    [extdata setValue:@"" forKey:@"s_session"];
    [params setValue:extdata forKey:@"extdata"];
    
    NSMutableDictionary *a_session = [NSMutableDictionary dictionary];
    [a_session setValue:@"a_12" forKey:@"a_123"];
    [a_session setValue:@"a_23" forKey:@"a_234"];
    [extdata setValue:a_session forKey:@"a_session"];
    NSMutableArray *b_session = [NSMutableArray array];
    [b_session addObject:@"b_12"];
    [b_session addObject:@"b_23"];
    [params setValue:b_session forKey:@"b_session"];
    
    return params;
}

/**
 (lldb) po params
 {
     "b_session" =     (
         "b_12",
         "b_23"
     );
     extdata =     {
         "a_session" =         {
             "a_123" = "a_12";
             "a_234" = "a_23";
         };
         "client_logid" = E18940390F8EC74785570C5BE86236F8;
         origin = feed;
         "s_session" = "";
     };
     key = 1762683039161549402;
     num = 20;
     "reply_id" = 1122518916369402407;
     "request_id" = 38383331323433303437373531393733353736;
     source = "channel_video_landing";
     "source_type" = baidumedia;
     start = 0;
     "topic_id" = 1000000056224844;
 }

 (lldb) po AFQueryStringFromParameters(params)
 b_session%5B%5D=b_12&b_session%5B%5D=b_23&extdata%5Ba_session%5D%5Ba_123%5D=a_12&extdata%5Ba_session%5D%5Ba_234%5D=a_23&extdata%5Bclient_logid%5D=E18940390F8EC74785570C5BE86236F8&extdata%5Borigin%5D=feed&extdata%5Bs_session%5D=&key=1762683039161549402&num=20&reply_id=1122518916369402407&request_id=38383331323433303437373531393733353736&source=channel_video_landing&source_type=baidumedia&start=0&topic_id=1000000056224844

 (lldb)
 */

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
