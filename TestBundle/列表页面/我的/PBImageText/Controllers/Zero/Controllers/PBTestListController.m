//
//  PBTestListController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestListController.h"
#import "PBTestListView.h"
#import "PBTestZeroEspressos.h"
#import "YYFPSLabel.h"
#import "TFHpple.h"
#import "PBContentModel.h"
#import "AFNetworking.h"

@interface PBTestListController ()

@property (nonatomic, weak) PBTestListView *testListView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, assign) NSInteger randomId;

@end

@implementation PBTestListController

- (void)requestData {
    //NSString *espressos = @"『乐翻了运动生态园』园区位于北京朝阳区孙河镇顺   <p>走进蹦床乐园立刻被快乐包围，这里充满着欢声笑语、炫动的灯光、炫酷的音乐</p>  @@从亲子互动到亲朋聚会一站式满足您的运动休闲生活。@@";
    
    //NSString *espressos = @"<p>\r\n\t　　空中宝马 至臻体验 冲上云霄\r\n</p>\r\n<p style=\"text-align:center;\">\r\n\t<img title=\"空中宝马 至臻体验 冲上云霄\" alt=\"空中宝马 至臻体验 冲上云霄\" src=\"https://static.dmcdn.cn/cfs/fun/content/2016/08/12/11/08b2cd82-4a2f-4a97-bed4-86496fa86b8f.jpg\" /> \r\n</p>\r\n<p>\r\n\t　　在生活节奏日渐加快的今日，我们举办此次飞行体验，目的为了让越来越多的人们能够体验到真正飞行的乐趣，而不是单一的感受民航里面超重失重。通过私人飞机高空灵活刺激的飞行技巧，绝对能够让肾上腺素急速飙升，心跳加快，压力彻底释放。或许会对您的身心、工作灵感、情感等起到很有利的效果。大家通过参加这次活动，相信会真正的爱上飞翔，爱上三维度空间自由驰骋的感觉。\r\n</p>\r\n<p style=\"text-align:center;\">\r\n\t<img src=\"https://static.dmcdn.cn/cfs/fun/content/2016/10/12/17/cc82ed88-e8e8-41b0-bc57-f4c5c89a8b26.jpg\" width=\"554\" height=\"369\" alt=\"\" /> \r\n</p>\r\n<p>\r\n\t<strong>　　活动包括：</strong> \r\n</p>\r\n<p>\r\n\t　　1、“空中宝马”西锐-SR20试驾试乘，低空飞行。\r\n</p>\r\n<p>\r\n\t　　2、每人可获得200万航空意外险\r\n</p>\r\n<p>\r\n\t　　本次活动试乘试驾飞行在八达岭机场举行，环绕长城飞行一周，\r\n</p>\r\n<p>\r\n\t　　坐于舒适的座舱，以一个崭新的视角，不同的海拔，俯瞰这被誉为世界“七大奇迹”之一的壮丽风景——中国长城之“八达岭长城”。飞行旅途经过野鸭湖湿地公园——康西大草原——八达岭南峰——北峰——好汉坡——烽火台等，于空中尽览八达岭长城的迷人风光。一定会让您享受到一次惊奇、刺激、奢华的旅行，圆您一个私人飞行的梦想。\r\n</p>\r\n<p style=\"text-align:center;\">\r\n\t<img src=\"https://static.dmcdn.cn/cfs/fun/content/2016/10/12/17/9e0a671b-aeca-48d5-936b-cee6d8205837.jpg\" alt=\"\" /> \r\n</p>\r\n<p>\r\n\t<strong>　　极致飞行体验：</strong> \r\n</p>\r\n<p>\r\n\t　　1. 起飞—右转—通过跑道—左转—俯冲—左转—低空通场—跃升—改平左转—失重体验—三转弯着陆\r\n</p>\r\n<p>\r\n\t　　2. 低速慢飞、俯冲、跃升、大坡度盘旋\r\n</p>\r\n<p>\r\n\t　　3. 基地机场起落航线\r\n</p>\r\n<p style=\"text-align:center;\">\r\n\t<img title=\"空中宝马 至臻体验 冲上云霄\" alt=\"空中宝马 至臻体验 冲上云霄\" src=\"https://static.dmcdn.cn/cfs/fun/content/2016/08/12/11/c844c55e-ee6b-4161-b1bc-771bdad881bb.jpg\" width=\"571\" height=\"310\" /> \r\n</p>\r\n<p>\r\n\t<strong>　　体验机型介绍：</strong> \r\n</p>\r\n<p>\r\n\t　　西锐Cirrus SR22是全球最为畅销的高性能单发4座复合型飞机，号称“空中宝马”。该机机长7.92米，高2.71米，翼展11.68米，飞机虽小，但性能卓越，输出达310马力，大亮点是装备了西锐整机降落伞系统(Cirrus Airframe Parachute System)，在紧急情况时，飞机打开降落伞便可实现安全降落。除了售价45万美元标准版的西锐Cirrus SR22外，SR22家族曾经还有SR22 G2、SR22 G3、SR22 T和SR22 TN等机型，2006年推出的旗舰版Cirrus SR22 GTS震惊业界，而Cirrus SR22 X版本更是奢华升级。如今Cirrus SR22还推出个性定制服务Xi，从飞机外部涂装到内部配饰，机主可与西锐Cirrus Xi团队一起设计打造属于自己的飞机。\r\n</p>\r\n<p style=\"text-align:center;\">\r\n\t<img title=\"空中宝马 至臻体验 冲上云霄\" alt=\"空中宝马 至臻体验 冲上云霄\" src=\"https://static.dmcdn.cn/cfs/fun/content/2016/08/12/11/17c31c0c-677e-4762-802f-ef1ef5da0159.jpg\" /> \r\n</p>\r\n<p style=\"text-align:center;\">\r\n\t<img title=\"空中宝马 至臻体验 冲上云霄\" alt=\"空中宝马 至臻体验 冲上云霄\" src=\"https://static.dmcdn.cn/cfs/fun/content/2016/08/12/11/f9ffcb40-8b76-477e-abb4-1b0c968175de.jpg\" width=\"567\" height=\"207\" /> \r\n</p>\r\n<p>\r\n\t　　时间：预约时间\r\n</p>\r\n<p>\r\n\t　　活动地点：八达岭机场\r\n</p>\r\n<p>\r\n\t　　报名方式：电话预约报名(13501088190)\r\n</p>\r\n<p>\r\n\t　　每天飞行时间：10：00-16：00\r\n</p>\r\n<p>\r\n\t　　每次飞行3人\r\n</p>\r\n<p>\r\n\t<strong>　　自驾线路</strong> \r\n</p>\r\n<p>\r\n\t　　北京城区上八达岭高速(G6)，经过居庸关、八达岭野生动物园至营城子(延庆城区)收费站出口下高速，出口左转即到\r\n</p>\r\n<p>\r\n\t<strong>　　公交线路</strong> \r\n</p>\r\n<p>\r\n\t　　德胜门或马甸桥南乘坐919路(快)，行至大浮坨站下车，向回走约1公里，至营城子收费站前右转进入航空路，即到。\r\n</p>\r\n<p>\r\n\t<strong>　　飞行小提示：</strong> \r\n</p>\r\n<p>\r\n\t　　1、佩戴太阳墨镜。在飞行观景方面起到非常好的避光效果，能够有效防止太阳光线照射影响飞行体验。\r\n</p>\r\n<p>\r\n\t　　2、涂防晒霜。\r\n</p>\r\n<p>\r\n\t　　3、携带好拍摄装备，请带上你的自拍杆，自拍神器等。\r\n</p>\r\n<p>\r\n\t　　4、手机确保流量充足，及时网络分享你快乐的瞬间。\r\n</p>\r\n<p>\r\n\t<strong>　　注意事项：</strong> \r\n</p>\r\n<p>\r\n\t　　飞行活动开始前，请配合工作人员填写身体健康声明和保险信息单。\r\n</p>\r\n<p>\r\n\t　　一.以下人员不宜参与飞行：\r\n</p>\r\n<p>\r\n\t　　1.传染性疾病患者\r\n</p>\r\n<p>\r\n\t　　2.精神病患者\r\n</p>\r\n<p>\r\n\t　　3.心脑血管疾病患者\r\n</p>\r\n<p>\r\n\t　　4.呼吸系统疾病患者\r\n</p>\r\n<p>\r\n\t　　5.做过胃肠手术的人员术后十天内不能乘坐飞机\r\n</p>\r\n<p>\r\n\t　　6.严重贫血的病人\r\n</p>\r\n<p>\r\n\t　　7.耳鼻喉病患者及临产孕妇。\r\n</p>\r\n<p>\r\n\t　　二.飞行前16小时内禁止饮酒。\r\n</p>\r\n<p>\r\n\t　　三.飞行前不宜空腹或吃得过饱，着装应保持宽松。\r\n</p>\r\n<p>\r\n\t　　四.上机严禁携带枪支、弹药、刀具及其它武器;严禁携带一切易燃、易爆、 剧毒、放射性物质等危险物品。\r\n</p>\r\n<p>\r\n\t　　五.上机时应当认真配合例行的安全检查;飞行时请系好自己的安全带;飞行期间严禁使用移动电话、手提电脑、电子式玩具等电子设备。\r\n</p>\r\n<p>\r\n\t　　六.上机要服从飞行教员的安排，切勿乱摸、乱动、拿走机上安全用品或私开安全门，不仅有可能犯法，还有可能危及自己和其他机上人员的生命安全。\r\n</p>\r\n<p>\r\n\t　　七.有晕车史的人员请事先服用晕机丸或嚼点口香糖，如果机上呕吐，请使用随机呕吐袋。在飞机爬升时,会有耳压变化，如感觉不适，您可以做吞咽动作来缓解。\r\n</p>\r\n<p>\r\n\t\r\n\r\n</p>\r\n<p>\r\n\t\r\n\r\n</p>\r\n<p>\r\n\t\r\n\r\n</p>\r\n<p>\r\n\t\r\n\r\n</p>";
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"pbimage_text" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *espressos = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSLog(@"espressos = %@", espressos);
    
    PBTestZeroEspressos *testZeroEspressos = [PBTestZeroEspressos testZeroEspressosWithHtmlStr:espressos];
    self.testListView.testZeroEspressos = testZeroEspressos;
    self.testListView.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];

    PBTestListView *testListView = [PBTestListView testListView];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    testListView.hidden = YES;
    
    [self requestData];
}

@end
