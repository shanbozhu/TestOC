//
//  PBDownload.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/9/9.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBDownload.h"
#import <AFNetworking/AFNetworking.h>
#import "PBSandBox.h"

@interface PBDownload ()

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, assign) NSInteger currentLength;
@property (nonatomic, assign) NSInteger fileLength;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, copy) NSString *filePath;

@end


@implementation PBDownload

+ (PBDownload *)download {
    return [[self alloc] init];
}

- (PBDownload *)init {
    if (self = [super init]) {
        self.filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"QQ_V5.4.0.dmg"];
    }
    return self;
}

- (void)startDownloadWithURL:(NSString *)urlStr block:(void(^)(NSInteger currentLength, NSInteger fileLength))block {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSInteger currentLength = [PBSandBox fileSizeAtPath:self.filePath];
    if (currentLength > 0) {
        self.currentLength = currentLength;
    }
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
            block(weakSelf.currentLength, weakSelf.fileLength);
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

- (void)suspendDownload {
    [self.task suspend];
}

- (void)continueDownload {
    [self.task resume];
}

- (void)cancelDownload {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:self.filePath]) {
        [manager removeItemAtPath:self.filePath error:nil];
    }
    
    [self.task cancel];
}

- (void)dealloc {
    [self.task cancel];
}

@end
