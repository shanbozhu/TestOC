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

- (NSString *)description {
    return [NSString stringWithFormat:@"filePath = %@, modifyTime = %lld, size = %lld", self.filePath, self.modifyTime, self.size];
}

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
 获取指定路径下的[文件]信息
 */
+ (PBSandBoxFileInfo *)fileInfoAtPath:(NSString *)filePath {
    struct stat st;
    if (lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
        PBSandBoxFileInfo *fileInfo = [[PBSandBoxFileInfo alloc] init];
        fileInfo.size = st.st_size;
        fileInfo.modifyTime = st.st_mtime;
        fileInfo.filePath = filePath;
        if (S_ISDIR(st.st_mode)) {
            fileInfo.size = [self fileSizeAtPath:filePath];
        }
        return fileInfo;
    }
    return nil;
}

/**
 获取指定路径下的[所有][文件]信息
 */
+ (NSArray *)fileInfosAtPath:(NSString *)filePath {
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory] || !isDirectory) {
        return nil;
    }
    
    NSMutableArray *fileInfoArr = [NSMutableArray array];
    for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:filePath error:nil]) {
        NSString *fullFilePath = [filePath stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullFilePath isDirectory:&isDirectory]) {
            PBSandBoxFileInfo *fileInfo = [self fileInfoAtPath:fullFilePath];
            [fileInfoArr addObject:fileInfo];
        }
    }
    
    return fileInfoArr;
}

/**
 获取指定路径下的[文件]大小
 */
+ (long long)fileSizeAtPath:(NSString *)filePath {
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        return 0;
    }
    
    if (!isDirectory) {
        return [self sizeAtPath:filePath];
    }
    
    long long size = 0;
    for (NSString *subFilePath in [fileManager enumeratorAtPath:filePath]) {
        NSString *fullFilePath = [filePath stringByAppendingPathComponent:subFilePath];
        if ([fileManager fileExistsAtPath:fullFilePath isDirectory:&isDirectory] && !isDirectory) {
            size += [self sizeAtPath:fullFilePath];
        }
    }
    return size;
}

+ (long long)sizeAtPath:(NSString *)filePath {
    struct stat st;
    if (lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
        return st.st_size;
    }
    return 0;
}

@end
