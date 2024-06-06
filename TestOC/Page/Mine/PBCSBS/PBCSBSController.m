//
//  PBCSBSController.m
//  TestOC
//
//  Created by shanbo on 2024/5/23.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBCSBSController.h"

@interface PBCSBSController ()

@end

/**
 浏览器地址栏发请求（ua此时可以放在请求头cookie里）给后端（后端此时可以从请求头cookie里拿到ua，这里的ua是给后端使用的），后端返回页面内容（纯字符串：html css js）给浏览器。（此时返回给不同浏览器是同一套页面内容，然后浏览器执行同一套js。）
 浏览器执行js可以读取浏览器本身的ua（这里的ua是给前端js使用的），根据不同的ua发不同的请求（或执行其他操作）返回不同的json，浏览器执行js根据返回的json操作DOM（此时不同ua的浏览器里就可以显示不同样式）
 */

/**
 文案可以在前端代码写死，反正前端代码也是在线拉取的。不过要改文案的话，需要前端重新上线(部署到服务器），而不是像后端可以开个配置平台直接配置，如果文案在后端代码写死也需要后端重新上线。
 前后端上线都要好于端发版，上线可以快速操作，发版需要更新App。
 */

@implementation PBCSBSController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    [self.view addSubview:bgImageView];
    bgImageView.frame = CGRectMake(10, 100, APPLICATION_FRAME_WIDTH - 20, APPLICATION_FRAME_WIDTH - 20);
    bgImageView.image = [UIImage imageNamed:@"pbcsbs.png"];
    
    UILabel *oneLab = [[UILabel alloc] init];
    [self.view addSubview:oneLab];
    oneLab.frame = CGRectMake(bgImageView.pb_left, bgImageView.pb_bottom + 20, bgImageView.pb_width, 10);
    oneLab.text = @"HTML：带布局信息";
    
    UILabel *twoLab = [[UILabel alloc] init];
    [self.view addSubview:twoLab];
    twoLab.frame = CGRectMake(bgImageView.pb_left, oneLab.pb_bottom + 20, bgImageView.pb_width, 10);
    twoLab.text = @"JSON：不带布局信息";
    
    UILabel *threeLab = [[UILabel alloc] init];
    [self.view addSubview:threeLab];
    threeLab.frame = CGRectMake(bgImageView.pb_left, twoLab.pb_bottom + 20, bgImageView.pb_width, 10);
    threeLab.text = @"蓝线：客户端发请求或浏览器发请求";
}

@end
