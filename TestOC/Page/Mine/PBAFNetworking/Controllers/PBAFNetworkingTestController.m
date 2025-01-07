//
//  PBAFNetworkingTestController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAFNetworkingTestController.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+BBAURL.h"

@interface PBAFNetworkingTestController ()

@end

@implementation PBAFNetworkingTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求路径、请求参数
    NSString *urlStr = @"https://mbd.baidu.com/searchbox?action=update&uuid=31CD314763DEA42D303CCDED424BC8BF42EF12&appname=tomas&branchname=tomas&cfrom=1025512a&ds_lv=4&ds_stc=0.7740&from=1025512a&fv=13.44.0.19&matrixstyle=1&mps=154326807&mpv=1&network=1_0&osbranch=i7&osname=baiduboxapp&puid=_u2Kt_OQv8SlmqqqB&service=bdbox&sid=35713_3-74953_5-72997_2-71741_6-35809_3-35412_1-77907_1-76140_2-35776_12-62205_2-35790_1-9580_5-35839_1-35870_1-79833_1-35832_3-78029_3-105949_1-79894_1-75001_2-35864_1-35719_1-5301_7550-80003_6-34336_1-35821_4-103916_8-32873_2-78752_3-35779_3-79203_3-30356_1-78040_1-73147_2-33497_1-78713_1-71552_5-77832_4-35873_10&st=0&submatrix=Tomas&ua=828_1792_iphone_2.30.0.0_0&uid=6D989E434574A6D38712A794674F6D74C81FC7309OLFQBBSCCC&zid=9TASkaL-1A1PjIZJkG-1CpxEMHpqPAMGnU9R9M2nVavACDd3ylgufV6_cvZwHIIcCh_qj-3hkxG-bAZ2h_cmmiw&lst=4&protocol=json&pv=1";
    
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
    [requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16C104 matrixstyle/1 SP-engine/2.82.0 bdapp/1.0 (tomas; tomas) tomas/2.30.0.0 (Baidu; P2 12.1.2)" forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"BAIDUID=BCBA998E4BCBC2CEF12D83D131F05C18:FG=1; bd_logap_verify=1; MBD_AT=1719382075; BDUSS=FdoVFlMTlhjVWRyVm1hS25RbWVZbDZKSlFrS05IdnRuYlBvd3lGTTk3ZVRPVzFtSVFBQUFBJCQAAAAAAAAAAAEAAAAKxaCGusPA1tTDztIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJOsRWaTrEVmb; BAIDUID_BFESS=BCBA998E4BCBC2CEF12D83D131F05C18:FG=1; BDUSS_BFESS=FdoVFlMTlhjVWRyVm1hS25RbWVZbDZKSlFrS05IdnRuYlBvd3lGTTk3ZVRPVzFtSVFBQUFBJCQAAAAAAAAAAAEAAAAKxaCGusPA1tTDztIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJOsRWaTrEVmb; ZFY=VmPK5L0A2ULdeiG:BWrcM6IW1TpfhCiw:BRKA4L:ABTB0I:C; b2b_first=1719494298; SP_FW_VER=3.820.2; fontsize=1.16; ST=0; iadexlist=550025316353; iadlist=550025316353; SCONF_PARAMS=NNw1ojaiej4KJAf8_a2ykkNlwojIa2iJq4DBYI5F-ioZa2I4_h2D9NI4xtgPPeo745w3ofOc2i_OuL8Hgavjh_agvi4qaviigNv18_ujD8g3uvhlYa2SiqqqB; WISE_HIS_PM=1; BAIDUCUID=_i-6tj8nvig3u28n0aS7ijul28lLu-iNga2Ua_iU2800O2u5lu2EijtvWuJW8SRAM6UmA; AFD_IP=211.95.58.9; H_WISE_SIDS=110085_295986_299594_500207_603328_298696_301026_282466_295818_607981_307086_608074_608717_608883_305467_607534_609307_609222_609510_609527_609576_607111_307653_609647_608152_608028_607027_609921_277936_609804_610002_609316_609606_610128_610110_610265_610427_610454_610120_610593_610630_610687_607725_295151_610760_610695_610813_610236_609947_610907_609089_610980_308060_604792_611132_610104_611171_611220_611240_611245_611259_611266_611263_611227_609050; BAIDULOCNEW=13523298.869980_3641065.962499_100000.00_289_1719802273000_1" forHTTPHeaderField:@"Cookie"];
    [requestSerializer setValue:@"https://m.baidu.com/s?tn=zbios&pu=sz%401320_480%2Ccuid%4045D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH%2Ccua%40828_1792_iphone_1.0.0.10_0%2Ccut%40iPhone11%2C8_12.1.2%2Cosname%40baiduboxapp%2Cosbranch%40i7%2Cctv%401%2Ccfrom%401005640h%2Ccsrc%40bdbox_tserch_txt%2Ccud%40REZCMkE2QjgtNkMzNy00MUEyLTgzRTEtQzMwNzk3RjhFQTRF&bd_page_type=1&word=%E5%BE%AE%E4%BF%A1%E5%B0%86%E6%8E%A8%E5%87%BA%E8%87%AA%E6%9C%89%E8%BE%93%E5%85%A5%E6%B3%95&sa=tkhr_3&ss=001001&network=1_0&from=1005640h&ant_ct=9%2BITzc9iee5%2F3Th%2BMIiUBqEXMBYcqM9RpZIkZRns%2Bxa8lKlxRUWJgmddGTCRGtet&rsv_sug4=8959&rsv_pq=16111291210279897629&oq=%E6%8B%9C%E7%99%BB%E5%90%AF%E7%A8%8B%E5%B0%B1%E8%81%8C%E5%91%8A%E5%88%AB%E6%B3%AA%E6%B4%92%E5%AE%B6%E4%B9%A1" forHTTPHeaderField:@"Referer"];
    
    // 请求体
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"{\"novel\":{\"tingshu_default_home\":\"9d49376840c3c66f3776e0a62a71c5a7\",\"tingshu_beginner_guide\":\"1b467c5cad14737a633165106b357003\",\"tingshu_top_tab\":\"9136f07ca740c83ad23291c2b6368aaf\",\"novel_auto_play\":\"0\"},\"flowvideo\":{\"flowvideo_conf\":\"31c22362e8a205402106bbad96b77dfa\"},\"scheme\":{\"no_trace\":\"0\",\"desc_patch\":\"0\"},\"searchVideo\":{\"searchvideo_flowvideo\":\"d2fc391eae1b4d25c61cbc5868ce4fec\"},\"account\":{\"menu_login_tips\":\"0\",\"accsrc\":\"0\"},\"personal_center\":{\"chest_personal_bar\":\"fba19440dd83c68b4aeab44799e09057\",\"clear_cache\":\"1566977593\",\"alert_img\":\"0\",\"home_img\":\"0\",\"setting_dsp_ad\":\"1638359894\"},\"usersetting\":{\"diskclean_guide\":\"0\"},\"bottom_bar_big_font\":{\"bottom_bar_big_font\":\"0\"},\"feed\":{\"feed_conf\":\"0\",\"push_config\":\"0\",\"landing_page_task_unregister\":\"0\",\"bear_pow_tips\":\"0\",\"feedtab\":\"358c2cc3fee89129693ad9957ea5897d\",\"feed_dislike_toast\":\"dc658c15ae4f44438e4515aeaf3fd3f6\",\"fancy_operation\":\"0\",\"tts_conf\":\"0\",\"note_banner\":\"0\",\"feed_operation_conf\":\"0\",\"feed_interest_selection\":\"ec46e8d513df934b7fcaa554adb6810d\",\"h2_domain\":\"0\",\"homepage_feed\":\"4a8496bc68f89ea8e2407100a8af9810\",\"h2_domain_network\":\"0\",\"kanting_conf\":\"0\",\"feed_personalise_guide\":\"0\",\"pull_refresh_info\":\"0\"},\"bottom_bar_red\":{\"bottom_bar_red\":\"0\"},\"location\":{\"location\":\"f96b4ef59aeb86772a2fc0e8e836c514\"},\"abtest\":{\"abtest\":\"12284023000\"},\"share\":{\"share_banner\":\"0\",\"share_operation\":\"0\"},\"video\":{\"nid_check\":\"6e9ffddf7059adb36f7b35466498b68a\",\"videoconf\":\"484f190e5b70d2405c4ff9d158f22c64\",\"videoautoplay\":\"6ecc00adc24b9b171f50e5318b3e2416\"},\"operation\":{\"tomas_emo_toast\":\"0\",\"skinlogo\":\"-1\",\"tomas_bar_bubble\":\"0\",\"shake\":\"0\",\"home_resource\":\"-1\"},\"mission_task\":{\"mission_ab_switch\":\"9ca47e437f75a848b39c96f77e40b671\",\"index_kit\":\"0\"},\"individuation\":{\"st\":\"448585770466803d7f439dedd663c0a9\"},\"bottom_bar\":{\"bottom_bar\":\"1708413969\"},\"home\":{\"light_framework\":\"0\",\"new_home_ctrl\":\"0\",\"user_model\":\"f99767fc5247165204aca2b0ddabdc9e\",\"custom_skin_update\":\"0\",\"search_frame_bar\":\"e4e754417e9c4db370bb64fde0ada535\",\"tomas_user_info\":\"1719566415\",\"launch_tab\":\"0\",\"user_channel_tomas\":\"ed21fcfe87120d8d66d79091f93f8146\",\"servicediamond\":\"0\",\"search_input_toast\":\"847c3c1ab2df1a6e31654fac8547495b\",\"tomas_fourth_tab\":\"1719566415\",\"callback_info\":\"0\",\"rtplus\":\"595082c966a3f51acc1592b4fcf0c0fe\",\"home_live_enter_op\":\"0\",\"hotwordcard\":\"0\",\"v1_tab\":\"-1\",\"index_tips_new\":\"-1\",\"v1_tab_operation\":\"0\",\"lite_search_bottom_tip\":\"e4e754417e9c4db370bb64fde0ada535\",\"index_guide\":\"0\",\"task_register\":\"0\",\"tab_text\":\"0\",\"newbusinesslink\":\"0\",\"task_popover\":\"0\",\"business_link\":\"0\",\"bubble_bar_tomas\":\"9cee6a72a8b3631ea23fe5cdbc7145c8\",\"home_live_enter\":\"0\"},\"new_member\":{\"new_member\":\"0\"},\"network\":{\"request_control\":\"0\"},\"new_feature\":{\"spotlight_blacklist\":\"1719566415\",\"icon\":\"0\",\"appscore\":\"0\"},\"hotdiscussion\":{\"hotdiscussion_conf\":\"0\"},\"umdata\":{\"umdata_conf\":\"0\"},\"word_command\":{\"is_silencescan\":\"0\"},\"hybrid\":{\"hybridTpl\":\"0\"},\"search\":{\"search_ernie\":\"-1\",\"search_ernie_op\":\"-1\",\"videotab_query\":\"0\",\"dynamic_query\":\"0\",\"search_ernie_bar\":\"0\",\"hot_search\":\"b033692dd235a74987d876744eeff845\"},\"splash\":{\"splash\":\"01719566415\"}}" forKey:@"version"];
    [params setValue:@"{\"hybrid\":{\"hybridTpl\":{\"injectjs\":\"20170614112922\",\"feed\":\"0\",\"profile\":\"20171102143659\",\"weather\":\"20170427154844\"}},\"splash\":{\"splash\":{\"is_block_shake_gesture\":\"0\",\"download_size_material\":\"00\",\"ipdx\":\"{\\\"id\\\":\\\"8C9E2296B4E3D003B40A156DF5FDD52F\\\",\\\"geocode\\\":\\\"\\\",\\\"ip\\\":\\\"180X169X253X135\\\",\\\"exptime\\\":1720334178}\",\"new_install_launch\":\"0\",\"iadex\":\"550025316353\",\"query\":\"40eAj6PmVWLabPB73B4rc7DWfSbqDa7pEByPsKEq9Wm73OTEWMXZktMaB8gNu-iiYavPfgapvf8pCbkxtM-mkfJgxojPJwzX9rxhoICXAq9UCEqv6hVhY6OAv8gEPvf6_a2oi_a6vgor0eY36PeAHWHSasERu2iXc1N4QxmyP-Gt-rd-KA9yW3m_Od15MXkPtMBA8gu6-ijJa2f6_av688C7bktZM-kAKFNnQLxPasxl28Xz7GIDWbFfPnLT-knwcQt5kzMhF9jKuv8WYuBYi_uivtgOubI98RFQkYRxPnAhBrXcK1t0SH3IavE62lXHKEI3WD1YOemjB4KZ6hVhY6OAv8gEPvf6_av6f_uEvgoz0eY36PexWWLTOTQV2IBucHIdQwL1OUSF-tedcQyDW3W7VN6hrVtmguvHfgOj28_Iu-8ug0s9_qrQVtqxBrX7K1t0SH1IaBHg-yvCK3l4WAG2PeGd-tX4KmNYWQ1wVI6_rVtmguvHfgOj28_IuviWg0s9_qrzVtqA2NXoKA5ESEWMP2w_BysSKE9jWwL_OUSF-tedcQyDW3W7VN6hrVtmguvHfgPq-8gZavisg0s9_qrWVtqx-JX5KA5ESEQhOcA1B82vKWNJQWm0a2E02lXHKWrxQLHMOcSP2rZT6hVhY6OAv8gEPvf6Ya2d8_uRv_or0eY36PVAHwSKaTGlv5T4KxiSSEDHaUS628sY7GIDWbFfPnLT-knwcQt5kzMhF9jKuv8WYu-6f_aN-tgOubII8RFQkYRxOcAFB4cF7DfOSbDqa7EU-8KIcE4xWmAhP-F5MXkMtMBA8gu6Bi_0u28Mguvb88C7bktZM-kAc1ivQLxPasx4B52Q7HI6SSDgOnEvByVqK3kRWLF7VN6hrVtmguvHf_ap2igKOvitg0s9gqrzVt6G-t-m7mitWQLqa7Gv-InfKmNnQ1mYOsSMBks46hVhY6OAv8gEO2i0_u2-8gaIBgoz0eY36PVGWFWAaUGh-5s17biTQEAfOUA1BJd3KLlyQmDXVN6_rVtmguvHf_ap2iYcu280g0s9gqrQVt6G-t-m7mitWQLqa7Gv-InfKmNnQ1mYOsSMBks46hVhY6OAv8gEO2i0_aBW8guIB_7rA\",\"feed_news\":\"40VGq9yZVfqQrxhX_avk8_uP2fgluvfY_u2Ki_uS-kzsMAYttMBAtYuG2N6_rVtmguvHfgPo2ijxa2iKg0s9g6plwz6aPV6sN5xbCYuJvtggavt6_u-68gaOv8_La-kCzMATYtMa-8_EaX9htMBA8gu6-igyu28eYOv4i8CkbkkKJE9MYMmvzf5GLfg5u2iu_OBqfYaS28_Ya28N_PVCI64tFY6mOv8o_aX7ktMuB8gNu-ii_u2Nt_aVB88CCbkxkJEk9YRwFYyFaBiRYu-S8_aNv8gjaB8g_uvEf6hZVztarVfxgO2fN6r9VtgGuvfqgO2qt_a_2ixlvaqAC\",\"sys_ua\":\"Mozilla\\/5.0 (iPhone; CPU iPhone OS 12_1_2 like Mac OS X) AppleWebKit\\/605.1.15 (KHTML, like Gecko) Mobile\\/16C104 matrixstyle\\/1 SP-engine\\/2.82.0\",\"is_invoke\":\"0\",\"adinfo\":{\"s\":[{\"k\":\"CP%2BP3AMQrpTcBxj8%2FfmzBiABKPSx0wkwADici%2FkCWABgAGgAcAB4gJn2swaAAf%2BylLUGiAH1B5ABAJgBAKABAK0BAAAAALEBAAAAAAAAAAC6AQIxNcABAMgBANUBAAAAANgBAOABAOgBAA%3D%3D\",\"t\":\"1719566239\"},{\"k\":\"CMrH2QMQ1d%2FaBxju2%2FmzBiABKPSx0wkwADjFuvgCWABgAGgAcAB4gJn2swaAAf%2B7%2B7MGiAH1B5ABAJgBAKABAK0BAAAAALEBAAAAAAAAAAC6AQIxNcABAMgBANUBAAAAANgBAOABAOgBAA%3D%3D\",\"t\":\"1719562069\"},{\"k\":\"CJ7W3AMQoPDaBxit9vmzBiAAKPSx0wkwADjJjPkCWABgAGgAcAB4gJn2swaAAf%2B7%2B7MGiAH1B5ABAJgBAKABAK0BAAAAALEBAAAAAAAAAAC6AQIxNcABAMgBANUBAAAAANgBAOABAOgBAA%3D%3D\",\"t\":\"1719566069\"},{\"k\":\"CNqt3QMQxbzbBxjb3vmzBiABKPSx0wkwADjDq%2FkCWABgAGgAcAB4gJn2swaAAf%2BylLUGiAH1B5ABAJgBAKABAK0BAAAAALEBAAAAAAAAAAC6AQIxNcABAMgBANUBAAAAANgBAOABAOgBAA%3D%3D\",\"t\":\"1719562708\"},{\"k\":\"CP%2BP3AMQrpTcBxjU7%2FmzBiABKPSx0wkwADici%2FkCWABgAGgAcAB4gJn2swaAAf%2BylLUGiAH1B5ABAJgBAKABAK0BAAAAALEBAAAAAAAAAAC6AQIxNcABAMgBANUBAAAAANgBAOABAOgBAA%3D%3D\",\"t\":\"1719564245\"},{\"k\":\"CPDy3QMQ5MvbBxjl0PmzBiABKPSx0wkwADjdsPkCWABgAGgAcAB4gPr3swaAAf%2B7%2B7MGiAH1B5ABAJgBAKABAK0BAAAAALEBAAAAAAAAAAC6AQDAAQDIAQDVAQAAAADYAQDgAQDoAQA%3D\",\"t\":\"1719560296\"},{\"k\":\"CMKt3QMQubzbBxjW0%2FmzBiABKPSx0wkwADjDq%2FkCWABgAGgAcAB4gJn2swaAAf%2BylLUGiAH1B5ABAJgBAKABAK0BAAAAALEBAAAAAAAAAAC6AQIxNcABAMgBANUBAAAAANgBAOABAOgBAA%3D%3D\",\"t\":\"1719561710\"},{\"k\":\"CIGc3gMQr4ncBxjn7vmzBiABKPSx0wkwADi1vPkCWABgAGgAcAB4gJn2swaAAf%2B7%2B7MGiAH1B5ABAJgBAKABAK0BAAAAALEBAAAAAAAAAAC6AQIxNcABAMgBANUBAAAAANgBAOABAOgBAA%3D%3D\",\"t\":\"1719564188\"}],\"d\":[],\"v\":\"01719566415\"},\"diskInfo\":{\"quota\":\"80\",\"size\":\"16\"},\"caidInfo\":{\"caids\":[{\"vendor\":\"0\",\"generateTime\":\"1719802273\",\"caid\":[{\"version\":\"00\",\"caid\":\"00_7EE015D0ED5C33FD1F69EFD9EEFB36D6_D806C5E0DF63A63F210230FF47F27BA0\"}]},{\"vendor\":\"1\",\"generateTime\":\"1719802273\",\"caid\":[{\"version\":\"20220111\",\"caid\":\"262fafbccc3d0dc97bdcf60e8cc14559\"},{\"version\":\"20230330\",\"caid\":\"62f122201fb4a47084a569b1f9f899ef\"}]},{\"vendor\":\"2\",\"generateTime\":\"1719382077\",\"caid\":[{\"version\":\"00\",\"caid\":\"E7A6034B-93CE-AA69-59F1-A50066D513DB\"}]}],\"factors_data\":\"8MAeoI5dwjtGkEjafpw4q6Pme86xhVzsNyxdqfrRS6fwiA6oIMBm_6r6m_fOpAoQkfAt695PbkYsMvtQgP2p8_aP-t6fheYmirSeqkyf36kfyVfxqu2f8juKv8gSO2Nr_O-qfgaoVNqa4mY79rxP_lJ2Ao6aPeamrMXZ9Np-wYph4ERZkpE9kYROv8gFa2iNYaBji6hkVzIM5moCIfA1qIMa-k0Zu-8i0avDi_auHagza-iO_OSo8g8Uv80Ba2iw0uH3u6h9VYkhpECP9pE7kYMw2tYOa29OzREAYtfJxqNtyF9mYM2s9zMxA6fkJVfm6uvEtjP328jHa-iN6hVh6IpBAjNY4EkPYMbA6zfSEqfnCHOs6heh694TEq6rPVPsYuv6aJMCX9kLJEux9rFKqppgmz69Pe8Q_aB_iguavi_Lh2t3gOvOf_OQ2kZZvqqSB\",\"caid_valid\":\"1\"},\"search\":\"y_VSkq5AwYIaOwqpNJF7YNyUsokTJsob9MXZ06MWeY935EfPfJm4oNyjmig5asowkJVhNaMHV9fAJxo9YJwvYfpQFqtiCAqv9MXZl6MzeY935EfPN5FP6Ip-AqIYpEN2Npw7kz_AV96i-t-m7mitWQLqa7Gv-InfKmNnQ1mYOsSMBks46h7P96MGP-FS2p29cxNDQbDIu7AE2l-LZHNeSFb5VIaIMV9uc1ivQLxPasx4B52Q7HI6SSDgOnEvByVqK3kRWLF7VNaPMV9ufJxfoj5BxYzF4b6RIpxkokydwINDpwkaz_VS9qB08ncwElQn33PVcm-k4e6Fh79Q6RxA6fykBYfUrsqUIJAcok4gszkfyXq2IrVhNaM6V9fAJxo9YJFuzIp3xokRyG6jkpbYINp2wkzm_V9gq5w3YIOAboIT4mq695wy6o4bm66Jh79Q6RxA6fyk-_9NJF_Mo4mv66h7796uRx6Sfy-M6tpPGYIdCA6s9MXZl6MzVW3DHPUD3B8M2cEhtSQimOZyb2fgVcEINQL8baUow-y92KEuySWiFVIdaMVo9KFvNQL9xasjx28NX7GeIWb1FPnhL-krncQLtkzZ_V9gq5w3YIPmGg9iCBfoo4mv6oybw9zs_V9gq5w3YIOmmqN95F6Qo4mv66h7796uRx6SfyBMYfryXof-rGio_as5zkJZVNa0MV9ufJxfoY0AmzkM4F6LkrmSoiJjsok3JVlG7qqSB\",\"client_request_time\":\"1719382075\",\"download_size_zip\":\"00\"}},\"account\":{\"accsrc\":{\"action\":\"login\",\"src\":\"personal_headerquicklogin\",\"type\":\"native\"}},\"home\":{\"tab_text\":{},\"rtplus\":{\"business\":{\"enter\":{\"bubble\":\"0\",\"reddot\":\"-1\"}},\"consumer\":{\"enter\":{\"bubble\":\"0\",\"reddot\":\"-1\"}}},\"index_guide\":{\"id\":\"0\"},\"task_register\":{\"isActive\":\"1\",\"isActiveSoundNovelTimer\":\"1\",\"isActiveSearch\":\"1\",\"isActiveSoundNovelFindBook\":\"1\",\"isFindBookTargetUser\":\"1\",\"productId\":\"14\"},\"newbusinesslink\":{\"list\":{}},\"new_home_ctrl\":{\"switch\":\"0\",\"switchReason\":\"\"},\"servicediamond\":{\"tipsVersion\":\"\",\"groupsVersion\":\"\"},\"search_input_toast\":{\"invokeChannel\":\"\"}},\"feed\":{\"feedtab\":{\"isNewHomePage\":\"0\",\"smartSortSwitch\":\"1\",\"tabs\":[{\"status\":\"0\",\"newTip\":\"0\",\"layout\":\"\",\"id\":\"109999289\",\"timestamp\":\"0\",\"name\":\"上海\",\"lastIntoTime\":\"1719566424\"},{\"status\":\"0\",\"newTip\":\"0\",\"layout\":\"\",\"id\":\"32\",\"timestamp\":\"0\",\"name\":\"小说\",\"lastIntoTime\":\"1719566392\"},{\"status\":\"0\",\"newTip\":\"0\",\"layout\":\"\",\"id\":\"8\",\"timestamp\":\"0\",\"name\":\"热搜\",\"lastIntoTime\":\"1719566393\"},{\"status\":\"0\",\"newTip\":\"0\",\"layout\":\"\",\"id\":\"192\",\"timestamp\":\"0\",\"name\":\"视频\",\"lastIntoTime\":\"1719802268\"}],\"isManualChangeCity\":\"0\",\"bubbleVersion\":{\"channel\":\"0\",\"plus\":\"0\"},\"newTipTapedNum\":\"0\"}},\"new_feature\":{\"appscore\":{\"app_V\":\"0\",\"time\":\"0\",\"choice\":\"0\"}},\"mission_task\":{\"index_kit\":{\"template\":[\"goldenEggStatus\"]}},\"usersetting\":{\"diskclean_guide\":{\"device_disk_size\":\"64\"}},\"video\":{\"nid_check\":{\"nids\":[\"sv_13830538911074797770\"]}}}" forKey:@"data"];
    [params setValue:@"{\"mktcoord\":\"13523298.869980,3641065.962499\",\"location\":\"121.480539,31.235929,---,100000.000000,1\",\"newNorm\":\"0\"}" forKey:@"pubdata"];
    return params;
}

- (void)processDataWithResponseObject:(id)responseObject {
    if ([responseObject isKindOfClass:[NSData class]]) {
        // jsonStr
        NSString *jsonStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"jsonStr = %@", jsonStr);
    }
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        // jsonDict
        NSDictionary *jsonDict = responseObject;
        NSLog(@"jsonDict = %@", jsonDict);
    }
}

@end
