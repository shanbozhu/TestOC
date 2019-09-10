//
//  PBDownload.h
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/9/9.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBDownload : NSObject

+ (PBDownload *)download;
- (void)startDownloadWithURL:(NSString *)urlStr progress:(void(^)(long long currentLength, long long fileLength))block;
- (void)suspendDownload;
- (void)continueDownload;
- (void)cancelDownload;

@end

NS_ASSUME_NONNULL_END
