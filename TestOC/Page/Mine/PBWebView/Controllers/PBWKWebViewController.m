//
//  PBWKWebViewController.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/12/30.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBWKWebViewController.h"
#import <WebKit/WebKit.h>

/**
 jsCalloc js端语句如下:
 var nativeDetailUrl = 'damai://V1/ProjectPage?id=' + id;
 window.webkit.messageHandlers.openPage.postMessage(nativeDetailUrl);
 */

@interface PBWKWebViewController ()<WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebViewConfiguration *configuration;
@property (nonatomic, weak) WKWebView *webView;

@end

@implementation PBWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    self.configuration = configuration;
    
    WKWebView *webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) configuration:configuration];
    self.webView = webView;
    [self.view addSubview:webView];
    webView.navigationDelegate = self;
    
    // 请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:self.urlStr]];
    
    {
        // ocCalljs 原始UA
        [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable userAgent, NSError * _Nullable error) {
            NSLog(@"userAgent = %@", userAgent);
            
            NSString *jsonStr = @"DamaiApp iOS v6.3.0";
            jsonStr = [userAgent stringByAppendingFormat:@" %@", jsonStr];
            
            // 设置新UA
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : jsonStr}];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    
    {
        //wkWebView 手动从NSHTTPCookieStorage获取cookie
        
        // 存储Cookie
        // oneCookie
        NSMutableDictionary *oneCookieDict = [NSMutableDictionary dictionary];
        oneCookieDict[NSHTTPCookieValue] = @"1";
        oneCookieDict[NSHTTPCookieName] = @"ma_maitian_client";
        oneCookieDict[NSHTTPCookiePath] = @"/";
        oneCookieDict[NSHTTPCookieDomain] = @".damai.cn";
        NSHTTPCookie *oneCookie = [NSHTTPCookie cookieWithProperties:oneCookieDict];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookie:oneCookie];
        
        // twoCookie
        NSMutableDictionary *twoCookieDict = [NSMutableDictionary dictionary];
        twoCookieDict[NSHTTPCookieValue] = @"userCode";
        twoCookieDict[NSHTTPCookieName] = @"damai.cn_maitian_user";
        twoCookieDict[NSHTTPCookiePath] = @"/";
        twoCookieDict[NSHTTPCookieDomain] = @".damai.cn";
        NSHTTPCookie *twoCookie = [NSHTTPCookie cookieWithProperties:twoCookieDict];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookie:twoCookie];
        
        // 拼接Cookie
        NSMutableString *cookieString = [NSMutableString string];
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies]) {
            if ([cookie.domain isEqualToString:@".damai.cn"]) {
                [cookieString appendString:[NSString stringWithFormat:@"%@=%@; ", cookie.name, cookie.value]];
            }
        }
        if ([cookieString rangeOfString:@";"].location != NSNotFound) {
            [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length-2, 2)];
        }
        
        // 设置Cookie
        [request addValue:cookieString forHTTPHeaderField:@"Cookie"];
    }
    
    NSLog(@"webView: allHTTPHeaderFields = %@", request.allHTTPHeaderFields);
    
    [webView loadRequest:request];
}

// 实现jsCalloc的方法定义
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"message.name = %@, message.body = %@", message.name, message.body);
    
    if ([message.name isEqualToString:@"openPage"]) {
        UIViewController *vc = [[UIViewController alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
        vc.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // jsCalloc
    [self.configuration.userContentController addScriptMessageHandler:self name:@"openPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"openPage"];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // ocCalljs
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"data = %@, error = %@", data, error);
    }];
    
    // ocCalljs
    NSString *param0 = @"1";
    NSString *jsStr = [NSString stringWithFormat:@"realNameThenticate('%@')", param0];
    [webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"data = %@, error = %@", data, error);
    }];
}

- (void)dealloc {
    NSLog(@"PBWKWebViewController对象被释放了");
}

@end
