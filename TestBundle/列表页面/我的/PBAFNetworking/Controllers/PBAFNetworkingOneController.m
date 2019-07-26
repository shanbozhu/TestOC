//
//  PBAFNetworkingOneController.m
//  TestBundle
//
//  Created by DaMaiIOS on 2018/1/18.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBAFNetworkingOneController.h"
#import <AFNetworking/AFNetworking.h>

@interface PBAFNetworkingOneController ()

@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) UILabel *lab;
@property (nonatomic, weak) UIButton *btn;
@property (nonatomic, weak) UIButton *oneBtn;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSProgress *progress;

@end

@implementation PBAFNetworkingOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // progressView
    UIProgressView *progressView = [[UIProgressView alloc]init];
    self.progressView = progressView;
    [self.view addSubview:progressView];
    progressView.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
    progressView.progress = 0;
    progressView.tintColor = [UIColor redColor];
    progressView.trackTintColor = [UIColor lightGrayColor];
    progressView.transform = CGAffineTransformMakeScale(1.0f, 2.0f);
    
    // lab
    UILabel *lab = [[UILabel alloc]init];
    self.lab = lab;
    [self.view addSubview:lab];
    lab.frame = CGRectMake(20, 130, [UIScreen mainScreen].bounds.size.width-40, 20);
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"0.00%";
    //lab.backgroundColor = [UIColor redColor];
    
    // btn
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn = btn;
    [self.view addSubview:btn];
    btn.frame = CGRectMake(20, 160, [UIScreen mainScreen].bounds.size.width-40, 40);
    [btn setTitle:@"开始下载" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    //btn.backgroundColor = [UIColor redColor];
    btn.tag = 0;
    
    // btn
    UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.oneBtn = btn;
    [self.view addSubview:oneBtn];
    oneBtn.frame = CGRectMake(20, 210, [UIScreen mainScreen].bounds.size.width-40, 40);
    [oneBtn setTitle:@"停止下载" forState:UIControlStateNormal];
    [oneBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [oneBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    //oneBtn.backgroundColor = [UIColor redColor];
    oneBtn.tag = 1;
}

- (void)btnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.tag == 0) {
        if (btn.selected == YES) {
            if ([btn.titleLabel.text isEqualToString:@"开始下载"]) {
                [self downloadTask];
            } else {
                [self.task resume];
            }
            
            [btn setTitle:@"暂停下载" forState:UIControlStateNormal];
        } else {
            [self.task suspend];
            
            [btn setTitle:@"恢复下载" forState:UIControlStateNormal];
        }
    }
    if (btn.tag == 1) {
        [self.task cancel];
        
        [self.btn setTitle:@"开始下载" forState:UIControlStateNormal];
        self.btn.selected = NO;
        
        self.progressView.progress = 0;
        self.lab.text = @"0.00%";
    }
}

- (void)downloadTask {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    
    NSURL *url = [NSURL URLWithString:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSProgress *progress;
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSString *filePath = [NSString stringWithFormat:@"%@/QQ_V5.4.0.dmg", path];
        NSURL *url = [NSURL fileURLWithPath:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        return url;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"filePath = %@", filePath);
    }];
    self.task = task;
    
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    self.progress = progress;
    
    [task resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"progress.fractionCompleted = %f", progress.fractionCompleted);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress.fractionCompleted;
            self.lab.text = [NSString stringWithFormat:@"%.2f%%", 100.0 * progress.fractionCompleted];
            
            if (self.progressView.progress == 1) {
                [self.btn setTitle:@"开始下载" forState:UIControlStateNormal];
                self.btn.selected = NO;
            }
        });
    }
}

- (void)dealloc {
    [self.task cancel];
    [self.progress removeObserver:self forKeyPath:@"fractionCompleted"];
    
    NSLog(@"PBAFNetworkingOneController对象被释放了");
}

@end
