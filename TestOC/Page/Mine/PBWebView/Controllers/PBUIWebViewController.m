//
//  PBUIWebViewController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBUIWebViewController.h"
#import "YYFPSLabel.h"
#import <JavaScriptCore/JavaScriptCore.h>


/**
 jsCalloc js端语句如下:
 htmlCallApp("updatePerformApp", JSON.stringify(ps));
 */

@interface PBUIWebViewController ()<UIWebViewDelegate>

@end

@implementation PBUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc]init];
    [self.view addSubview:webView];
    webView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    webView.delegate = self;
    
    // 请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    {
        // ocCalljs 原始UA
        NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSLog(@"userAgent = %@", userAgent);
        
        NSDictionary *dict = @{@"imei" : @"653A4622-5438-46A5-9C9A-EFFEA2DB2DE5", @"WebView" : @"UIWebView", @"userId" : @"62", @"token" : @"99a71b2b9cb39c8fcf84cf48c54b1abd", @"platform_id" : @"100"};
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        jsonStr = [userAgent stringByAppendingFormat:@" %@", jsonStr];
        
        // 设置新UA
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : jsonStr}];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    {
        // 存储Cookie
        // oneCookie
        NSMutableDictionary *oneCookieDict = [NSMutableDictionary dictionary];
        oneCookieDict[NSHTTPCookieName] = @"ma_maitian_client";
        oneCookieDict[NSHTTPCookieValue] = @"1";
        oneCookieDict[NSHTTPCookieDomain] = @".damai.cn";
        oneCookieDict[NSHTTPCookiePath] = @"/";
        NSHTTPCookie *oneCookie = [NSHTTPCookie cookieWithProperties:oneCookieDict];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:oneCookie];
        
        // twoCookie
        NSMutableDictionary *twoCookieDict = [NSMutableDictionary dictionary];
        twoCookieDict[NSHTTPCookieName] = @"damai.cn_maitian_user";
        twoCookieDict[NSHTTPCookieValue] = @"userCode";
        twoCookieDict[NSHTTPCookieDomain] = @".damai.cn";
        twoCookieDict[NSHTTPCookiePath] = @"/";
        NSHTTPCookie *twoCookie = [NSHTTPCookie cookieWithProperties:twoCookieDict];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:twoCookie];
        
        // 拼接Cookie
        NSMutableString *cookieString = [NSMutableString string];
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            if ([cookie.domain isEqualToString:@".damai.cn"]) {
                [cookieString appendString:[NSString stringWithFormat:@"%@=%@; ", cookie.name, cookie.value]];
            }
        }
        if ([cookieString rangeOfString:@";"].location != NSNotFound) {
            [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 2, 2)];
        }
        
        // 设置Cookie
        [request setValue:cookieString forHTTPHeaderField:@"Cookie"];
    }
    
    NSLog(@"UIWebView: allHTTPHeaderFields = %@", request.allHTTPHeaderFields);
    
    [webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // ocCalljs
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"title = %@", title);
    
    // jsCalloc
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
    };
    
    __weak JSContext *weakContext = context;
    
    __weak typeof(self)weakSelf = self;
    context[@"htmlCallApp"] = ^() {
        NSLog(@"weakContext = %@", weakContext);
        
        // args数组一般含有两个元素,第一个元素是方法名(字符串),第二个元素是参数(json字符串)
        NSArray *arguments = [JSContext currentArguments];
        
        NSMutableArray *objs = [NSMutableArray array];
        for (int i = 0; i < arguments.count; i++) {
            JSValue *value = [arguments objectAtIndex:i];
            
            [objs addObject:[value toString]];
        }
        NSLog(@"objs = %@", objs);
        
        NSString *param0 = [NSString stringWithFormat:@"%@:", objs[0]];
        NSString *param1 = objs[1];
        
        NSData *data = [param1 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSString *ocReturn = nil;
        SEL selector = NSSelectorFromString(param0);
        if ([weakSelf respondsToSelector:selector]) {
            ocReturn = [weakSelf performSelector:selector withObject:jsonDict];
        }
        NSLog(@"ocReturn = %@", ocReturn);
        
        return ocReturn;
    };
    
    // ocCalljs
    NSString *param0 = @"finishLoad";
    NSString *param1 = @"helloworld";
    NSString *jsStr = [NSString stringWithFormat:@"appCallHtml('%@', '%@')", param0, param1];
    NSString *jsReturn = [webView stringByEvaluatingJavaScriptFromString:jsStr];
    NSLog(@"jsReturn = %@", jsReturn);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

// 实现jsCalloc的方法定义
- (NSString *)setAppGobackBar:(NSDictionary *)param {
    NSLog(@"param = %@", param);
    return param[@"native_code"];
}

- (NSString *)addPerformAppfoot:(NSDictionary *)param {
    NSLog(@"param = %@", param);
    return param[@"url"];
}

- (void)dealloc {
    NSLog(@"PBUIWebViewController对象被释放了");
}

@end
