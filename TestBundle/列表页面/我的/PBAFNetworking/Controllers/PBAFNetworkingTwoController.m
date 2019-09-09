//
//  PBAFNetworkingTwoController.m
//  TestBundle
//
//  Created by DaMaiIOS on 2018/1/18.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBAFNetworkingTwoController.h"
#import <AFNetworking/AFNetworking.h>
#import "PBSandBox.h"

@interface PBAFNetworkingTwoController ()

@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) UILabel *lab;
@property (nonatomic, weak) UIButton *btn;
@property (nonatomic, weak) UIButton *oneBtn;
@property (nonatomic, weak) UIButton *twoBtn;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSProgress *progress;

@property (nonatomic, assign) NSInteger currentLength;
@property (nonatomic, assign) NSInteger fileLength;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, copy) NSString *filePath;

@end

@implementation PBAFNetworkingTwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"QQ_V5.4.0.dmg"];
    
    //progressView
    UIProgressView *progressView = [[UIProgressView alloc]init];
    self.progressView = progressView;
    [self.view addSubview:progressView];
    progressView.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
    progressView.progress = 0;
    progressView.tintColor = [UIColor redColor];
    progressView.trackTintColor = [UIColor lightGrayColor];
    progressView.transform = CGAffineTransformMakeScale(1.0f, 2.0f);
    
    //lab
    UILabel *lab = [[UILabel alloc]init];
    self.lab = lab;
    [self.view addSubview:lab];
    lab.frame = CGRectMake(20, 130, [UIScreen mainScreen].bounds.size.width-40, 20);
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"0.00%";
    //lab.backgroundColor = [UIColor redColor];
    
    //btn
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn = btn;
    [self.view addSubview:btn];
    btn.frame = CGRectMake(20, 160, [UIScreen mainScreen].bounds.size.width-40, 40);
    [btn setTitle:@"开始下载" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    //btn.backgroundColor = [UIColor redColor];
    btn.tag = 0;
    
    //btn
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
            NSInteger currentLength = [PBSandBox fileSizeAtPath:self.filePath];
            if (currentLength > 0) {
                self.currentLength = currentLength;
            }
            
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
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:self.filePath]) {
            [manager removeItemAtPath:self.filePath error:nil];
        }
        
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 设置http请求头中的range
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.currentLength];
    [request setValue:range forHTTPHeaderField:@"range"];
    
    __weak typeof(self)weakSelf = self;
    [manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
        NSLog(@"开始下载1 = %@, response.expectedContentLength = %lf, weakSelf.currentLength = %lf", [NSThread currentThread], (response.expectedContentLength / 1024.0 / 1024.0), (weakSelf.currentLength / 1024.0 / 1024.0));
        
        // response.expectedContentLength表示还需要下载的内容长度
        weakSelf.fileLength = response.expectedContentLength + weakSelf.currentLength;
        NSLog(@"weakSelf.fileLength = %ld", weakSelf.fileLength);
        
        
        [PBSandBox createFileAtPath:self.filePath];
        weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
        return NSURLSessionResponseAllow;
    }];
    
    [manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        NSLog(@"正在下载2 = %@, data.length = %ld", [NSThread currentThread], data.length);
        
        [weakSelf.fileHandle seekToEndOfFile];
        [weakSelf.fileHandle writeData:data];
        
        weakSelf.currentLength = weakSelf.currentLength + data.length;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = 1.0 * weakSelf.currentLength / weakSelf.fileLength;
            weakSelf.lab.text = [NSString stringWithFormat:@"%.2f%%", 100.0 * weakSelf.currentLength / weakSelf.fileLength];
            if (weakSelf.progressView.progress == 1) {
                [weakSelf.btn setTitle:@"开始下载" forState:UIControlStateNormal];
                weakSelf.btn.selected = NO;
            }
        });
    }];
    
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"下载完成3 = %@, filePath = %@", [NSThread currentThread], self.filePath);
        
        // 下载完成执行的操作
        weakSelf.currentLength = 0;
        weakSelf.fileLength = 0;
        
        [weakSelf.fileHandle closeFile];
        weakSelf.fileHandle = nil;
    }];
    self.task = task;
    
    [task resume];
}

- (void)dealloc {
    [self.task cancel];
    
    NSLog(@"PBAFNetworkingTwoController对象被释放了");
}

@end
