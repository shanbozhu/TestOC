//
//  PBActivityDetailContent.m
//  TestOC
//
//  Created by DaMaiIOS on 2016/11/11.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBActivityDetailContent.h"

@implementation PBActivityDetailContent

+ (id)activityDetailContentWithHtmlStr:(NSString *)htmlStr {
    // 该类对象不一定要返回，因为在外面可以选择不接收该类对象，直接接收需要的数据类型的值
    //return [[self alloc]initWithHtmlStr:HtmlStr];
    PBActivityDetailContent *activityDetailContent = [[self alloc]initWithHtmlStr:htmlStr];
    return activityDetailContent;
}

- (id)initWithHtmlStr:(NSString *)htmlStr {
    if ([super init]) {
        // 测试数据
        //htmlStr = @"<p><strong><img alt=\"1360207858178.jpg\" width=350 height=250 title=\"1360207858178.jpg\" src=\"http://img3.cache.netease.com/auto/2016/4/20/2016042020445079088_550.jpg\"/>【演出项目】 </strong><strong>BIGBANG2015世界巡演 [MADE] 杭州站</strong><br/><strong> 【演出时间】 2015.08.25</strong><br/><strong> <img alt=\"1360207858178.jpg\" width=350 height=250 title=\"1360207858178.jpg\" src=\"http://mtimg.damai.cn/maitian/app/news/2016/06/1466474673341_1600_720.jpg\">【演出场馆】 黄龙体育中心</strong><br/><strong>【演出票价】 待定</strong><br/><strong> 【购票地址】 待定</strong><br/><br/>为了方便大家及时了解演唱会最新消息，以及票务消息，特针对本麦田会员做“演唱会消息订阅”的活动。<br/><br/>★参加本次活动报名的VIP，在演唱会消息确定后将会【提前】收到票务信息的短信通知！<img src=\"http://mtimg.damai.cn/maitian/app/news/2016/07/1468983298003_1600_720.jpg\"/><br/>★本活动不收取任何费用，不代表门票免费！演唱会消息确定后，请前往购票页面购买演唱会门票！<img src=\"http://mtimg.damai.cn/maitian/app/topic/2016/11/1478682688327_750_420.jpg\"><br/><br/><strong> 活动参与步骤：</strong><br/><strong> （1）点击“报名”；</strong><br/><strong> （2）填写你的邮箱地址和手机号码；</strong><br/><strong> （3）提交。</strong><br/>注：本活动仅针对本麦田会员，请在页面上方点击“加入”。否则是无法报名的哦！<br/><br/><strong> 更多消息请关注</strong><br/>BIGBANG资讯台:<br/><a href=\"https://www.baidu.com/\" target=\"_blank\">https://www.baidu.com/<br/></a><br/>大麦网杭州站<br/><a href=\"http://weibo.com/damaihangzhou\">http://weibo.com/damaihangzhou</a></p>";
        
        // 替换中文空格
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"　　" withString:@""];
        // 符号"/>中间添加空格
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\"/>" withString:@"\" />"];
        // 符号">中间添加空格
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\">" withString:@"\" >"];
        // 替换图片给定宽度
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"width=" withString:@"widt h="];
        // 替换图片给定高度
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"height=" withString:@"heigh t="];
        // 替换图片给定alt
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"alt=" withString:@"al t="];
        
        // 拼接html字符串
        htmlStr = [self pieceTogetherHtmlStr:htmlStr];
        
        // 去除首尾空格和换行
        htmlStr = [htmlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // 保存Html字符串
        self.htmlStr = htmlStr;
    }
    return self;
}

- (NSString *)pieceTogetherHtmlStr:(NSString *)htmlStr {
    NSMutableString *completeHtmlStr = [NSMutableString string];
    
    // 开始html
    [completeHtmlStr appendFormat:@"<html>"];
    
    // 添加html头
    [completeHtmlStr appendFormat:@"<head>"];
    [completeHtmlStr appendFormat:@"<link rel=\"stylesheet\" href=\"%@\">", [[NSBundle mainBundle] URLForResource:@"PBActivityDetail.css" withExtension:nil]];
    [completeHtmlStr appendFormat:@"<script src=\"%@\"></script>", [[NSBundle mainBundle] URLForResource:@"PBActivityDetail.js" withExtension:nil]];
    [completeHtmlStr appendFormat:@"</head>"];
    
    // 添加html体
    [completeHtmlStr appendFormat:@"<body>"];
    [completeHtmlStr appendFormat:@"%@", [self pieceTogetherBodyStr:htmlStr]];
    [completeHtmlStr appendFormat:@"</body>"];
    
    // 结束html
    [completeHtmlStr appendFormat:@"</html>"];
    
    return completeHtmlStr;
}

- (NSString *)pieceTogetherBodyStr:(NSString *)htmlStr {
    NSMutableString *bodyStr = [NSMutableString string];
    [bodyStr appendFormat:@"%@", htmlStr];
    
    // 获取所有形如 src="http://mtimg.damai.cn/maitian/app/topic/2016/08/1470452349776_510_360.jpg" 的字符串
    NSMutableArray *srcArr = [NSMutableArray array];
    NSMutableArray *urlArr = [NSMutableArray array];
    NSArray *arr = [htmlStr componentsSeparatedByString:@" "];
    for (NSString *str in arr) {
        if ([str rangeOfString:@"src="].location != NSNotFound) {
            // 获取含有src的字符串
            [srcArr addObject:str];
            
            // 获取去掉src的图片地址字符串
            if ([str rangeOfString:@"\""].location != NSNotFound) {
                NSString *url = [[str componentsSeparatedByString:@"\""] objectAtIndex:1];
                [urlArr addObject:url];
            } else {
                return htmlStr;
            }
        }
    }
    // 保存图片数组
    self.imageArr = urlArr;
    
    // 拼接图片Html
    for (int i = 0; i < srcArr.count; i++) {
        // 获取缩放后的图片宽度和高度
        CGFloat imageWidth = kPBSWidth-10-10;
        CGFloat imageHeight = 0;
        
        NSString *urlStr = urlArr[i];
        NSArray *sizeArr = [urlStr componentsSeparatedByString:@"."];
        for (NSString *sizeStr in sizeArr) {
            if ([sizeStr rangeOfString:@"_"].location != NSNotFound) {
                // 返回的url形式为 宽度*高度
                CGFloat indeedImageWidth = 0, indeedImageHeight = 0;
                NSArray *tmpArr = [sizeStr componentsSeparatedByString:@"_"];
                if (tmpArr.count > 1) {
                    indeedImageWidth = [[tmpArr objectAtIndex:1] floatValue];
                }
                if (tmpArr.count > 2) {
                    indeedImageHeight = [[tmpArr objectAtIndex:2] floatValue];
                }
                
                imageHeight = imageWidth / indeedImageWidth * indeedImageHeight;
            }
        }
        
        NSMutableString *imageHtmlStr = [NSMutableString string];
        //[imageHtmlStr appendFormat:@"src=\"%@\" width=\"%f\" height=\"%f\" onclick=\"imgClick(this.src, this.clientWidth, this.clientHeight, this.getBoundingClientRect().top)\"", urlStr, imageWidth, imageHeight];
        
        // 高度也可以不用设置,会自动适应
        [imageHtmlStr appendFormat:@"src=\"%@\" alt=\"%d\" width=\"%f\" onclick=\"imgClick(this.src, this.alt, this.clientWidth, this.clientHeight, this.getBoundingClientRect().top)\" style=\"height:auto !important;\"", urlStr, i, imageWidth];
        [bodyStr replaceOccurrencesOfString:srcArr[i] withString:imageHtmlStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, bodyStr.length)];
    }
    return bodyStr;
}

- (void)dealloc {
    NSLog(@"PBActivityDetailContent对象被释放了");
}

@end
