//
//  PBDownload.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/9/9.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBDownload.h"
#import <AFNetworking/AFNetworking.h>
#import "PBSandBox.h"
#import "NSString+BBAEncode.h"

@interface PBDownload ()

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) long long downloadedSize;
@property (nonatomic, assign) long long totalSize;
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, copy) void(^progress)(long long downloadedSize, long long totalSize);

@end

@implementation PBDownload

#pragma mark - 下载操作

+ (PBDownload *)download {
    return [[PBDownload alloc] init];
}

- (void)startDownloadWithURL:(NSString *)urlStr progress:(void(^)(long long downloadedSize, long long totalSize))progress {
    self.urlStr = urlStr;
    self.progress = progress;
    
    // 创建空下载文件
    [self createDownloadFileWithURL:urlStr];
    
    // 向空下载文件中填充数据
    [self requestDataWithURL:urlStr progress:progress];
}

- (void)suspendDownload {
    //[self.task suspend];
    [self.task cancel];
    self.task = nil;
}

- (void)continueDownload {
    //[self.task resume];
    [self startDownloadWithURL:self.urlStr progress:self.progress];
}

- (void)cancelDownload {
    [self.task cancel];
    [PBSandBox deleteFileOrDirectoryAtPath:self.filePath];
}

#pragma mark - 下载请求

- (void)requestDataWithURL:(NSString *)urlStr progress:(void(^)(long long downloadedSize, long long))progress {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    __weak typeof(self)weakSelf = self;
    [manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse.statusCode == 200) { // 状态码为206是服务器支持分段下载文件
            // 状态码为200是服务器不支持分段下载文件,每个下载任务只能从0开始至全部下载
            [PBSandBox deleteFileOrDirectoryAtPath:weakSelf.filePath];
            [PBSandBox createFileAtPath:weakSelf.filePath];
            weakSelf.downloadedSize = 0;
        }
        
        // 下载文件总大小
        weakSelf.totalSize = response.expectedContentLength + weakSelf.downloadedSize;
        NSLog(@"开始下载 = %@, expectedContentLength = %lld, downloadedSize = %lld, weakSelf.totalSize = %lld", [NSThread currentThread], response.expectedContentLength, weakSelf.downloadedSize, weakSelf.totalSize);
        
        weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:weakSelf.filePath];
        return NSURLSessionResponseAllow;
    }];
    
    [manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        NSLog(@"正在下载 = %@, data.length = %ld", [NSThread currentThread], data.length);
        
        [weakSelf.fileHandle seekToEndOfFile];
        [weakSelf.fileHandle writeData:data];
        
        weakSelf.downloadedSize = weakSelf.downloadedSize + data.length;
        dispatch_async(dispatch_get_main_queue(), ^{
            progress(weakSelf.downloadedSize, weakSelf.totalSize);
        });
    }];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    // 设置http请求头中的Range,通知服务器下载文件的哪一段,从已经下载的大小到整个文件
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-", self.downloadedSize];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    self.task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"下载完成 = %@, filePath = %@", [NSThread currentThread], weakSelf.filePath);
        
        [weakSelf.fileHandle closeFile];
        weakSelf.fileHandle = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            progress(weakSelf.downloadedSize, weakSelf.totalSize);
        });
    }];
    
    [self.task resume];
}

- (void)createDownloadFileWithURL:(NSString *)urlStr {
    NSString *fileName = [urlStr bdp_md5Hash];
    // 指定路径创建文件
    self.filePath = [PBSandBox absolutePathWithRelativePath:[NSString stringWithFormat:@"/Documents/PBDownload/%@", fileName]];
    [PBSandBox createFileAtPath:self.filePath];
    
    // 本地已经下载的文件大小
    self.downloadedSize = [PBSandBox fileSizeAtPath:self.filePath];
}

- (void)dealloc {
    [self.task cancel];
    NSLog(@"PBDownload对象被释放了");
}

@end
