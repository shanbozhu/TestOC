//
//  PBSandBox.m
//  TestBundle
//
//  Created by DaMaiIOS on 16/3/31.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBSandBox.h"
#import <sys/stat.h>

@implementation PBSandBoxFileInfo



@end

@implementation PBSandBox

+ (NSString *)path4Home {
    return NSHomeDirectory();
}

+ (NSString *)path4Documents {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
}

+ (NSString *)path4Library {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)lastObject];
}

+ (NSString *)path4LibraryCaches {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
}

+ (NSString *)path4Tmp {
    return NSTemporaryDirectory();
}

/**
 获取指定路径下的文件信息
 */
+ (PBSandBoxFileInfo *)fileInfoAtPath:(NSString *)filePath {
    struct stat st;
    if (lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
        PBSandBoxFileInfo *fileInfo = [[PBSandBoxFileInfo alloc] init];
        fileInfo.size = st.st_size;
        fileInfo.modifyTime = st.st_mtime;
        fileInfo.filePath = filePath;
        if (S_ISDIR(st.st_mode)) {
            fileInfo.size = [self directorySizeAtPath:filePath];
        }
        return fileInfo;
    }
    return nil;
}

/**
 获取指定路径下的[目录文件]的[实际]大小
 */
+ (long long)directorySizeAtPath:(NSString *)directory {
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDirectory] || !isDirectory) {
        return 0;
    }
    
    long long size = 0;
    for (NSString *filePath in [fileManager enumeratorAtPath:directory]) {
        NSString *fullFilePath = [directory stringByAppendingPathComponent:filePath];
        if ([fileManager fileExistsAtPath:fullFilePath isDirectory:&isDirectory] && !isDirectory) {
            size += [self fileSizeAtPath:fullFilePath];
        }
    }
    return size;
}

/**
 获取指定路径下的[文件]大小
 */
+ (long long)fileSizeAtPath:(NSString *)filePath {
    struct stat st;
    if (lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
        return st.st_size;
    }
    return 0;
}

@end
