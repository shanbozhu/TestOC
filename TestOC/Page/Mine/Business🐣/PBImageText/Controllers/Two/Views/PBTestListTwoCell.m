//
//  PBTestListTwoCell.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/6/26.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBTestListTwoCell.h"
#import "PBPhotoBrowserView.h"

@interface PBTestListTwoCell ()<UIWebViewDelegate, PBPhotoBrowserViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@end

@implementation PBTestListTwoCell

+ (id)testListTwoCellWithTableView:(UITableView *)tableView {
    PBTestListTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBTestListTwoCell"];
    if (!cell) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PBTestListTwoCell"];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // webView
        UIWebView *webView = [[UIWebView alloc] init];
        self.webView = webView;
        [self.contentView addSubview:webView];
        webView.scrollView.scrollEnabled = NO;
        webView.delegate = self;
        webView.frame = CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width - 10 - 10, 1);
        webView.layer.borderColor = [UIColor redColor].CGColor;
        webView.layer.borderWidth = 1.1;
    }
    return self;
}

- (void)setTestTwoEspressos:(PBTestTwoEspressos *)testTwoEspressos {
    _testTwoEspressos = testTwoEspressos;
    [self fillTestListTwoCell];
}

- (void)fillTestListTwoCell {
    // 设置webView高度
    CGRect rect = self.webView.frame;
    rect.size.height = self.testTwoEspressos.height;
    self.webView.frame = rect;
    
    [self.webView loadHTMLString:self.testTwoEspressos.activityDetailContent.htmlStr baseURL:nil];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, CGRectGetMaxY(self.webView.frame)==0?0.000001:CGRectGetMaxY(self.webView.frame));
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    
    NSLog(@"1111 = %lf", height);
    if (self.testTwoEspressos.height != height) {
        self.testTwoEspressos.height = height;
        [self.testTwoEspressos.tableView reloadData];
        
    }
    NSLog(@"3333 = %lf", self.testTwoEspressos.height);
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlStr = [NSString stringWithFormat:@"%@", request.URL];
    NSLog(@"urlStr = %@", urlStr);
    
    // 点击了h5内部的链接
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        // do someting
        return NO;
    }
    
    if ([urlStr rangeOfString:@"sx:http"].location != NSNotFound) {
        NSArray *tmpArr = [urlStr componentsSeparatedByString:@"&"];
        NSLog(@"src = %@, index = %@, width = %@, height = %@, top = %@", [tmpArr[0] substringFromIndex:3], tmpArr[1], tmpArr[2], tmpArr[3], tmpArr[4]);
        
        // 启动图片浏览器
        PBPhotoBrowserView *photoBrowserView = [PBPhotoBrowserView photoBrowserView];
        photoBrowserView.sourceImageFatherView = nil; //原图的父控件
        photoBrowserView.imageCount = self.testTwoEspressos.activityDetailContent.imageArr.count;
        photoBrowserView.currentImageIndex = [tmpArr[1] integerValue];
        photoBrowserView.delegate = self;
        [photoBrowserView show];
        
        return NO;
    }
    return YES;
}

// 缩略图视图
- (UIImageView *)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andThumbImageURLWithIndex:(NSInteger)index {
    return nil;
}

// 高清图地址
- (NSURL *)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andHDImageURLWithIndex:(NSInteger)index {
    NSString *imageUrl = self.testTwoEspressos.activityDetailContent.imageArr[index];
    imageUrl = [self newStringCutOffWithOldSting:imageUrl];
    return [NSURL URLWithString:imageUrl];
}

- (NSString *)newStringCutOffWithOldSting:(NSString *)oldSting {
    NSRange range1 = [oldSting rangeOfString:@"_"];
    if (range1.location != NSNotFound) {
        NSRange range2 = [oldSting rangeOfString:@"." options:NSBackwardsSearch];
        NSInteger length = range2.location - range1.location;
        NSString *subUrl = [oldSting substringWithRange:NSMakeRange(range1.location, length)];
        NSString *newString = [oldSting stringByReplacingOccurrencesOfString:subUrl withString:@""];
        return newString;
    } else {
        return oldSting;
    }
}

- (void)dealloc {
    NSLog(@"PBTestListTwoCell对象被释放了");
}

@end
