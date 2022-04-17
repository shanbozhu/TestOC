//
//  PBDownload.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/9/9.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBDownload : NSObject

+ (PBDownload *)download;

/**
 开始下载
 
 @param urlStr 文件的下载地址
 @param progress 文件的下载进度
 */
- (void)startDownloadWithURL:(NSString *)urlStr progress:(void(^)(long long downloadedSize, long long totalSize))progress;

/**
 暂停下载
 */
- (void)suspendDownload;

/**
 继续下载
 */
- (void)continueDownload;

/*
 取消下载
 */
- (void)cancelDownload;

@end

NS_ASSUME_NONNULL_END
