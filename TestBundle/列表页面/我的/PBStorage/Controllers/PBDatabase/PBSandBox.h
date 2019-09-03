//
//  PBSandBox.h
//  TestBundle
//
//  Created by DaMaiIOS on 16/3/31.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import <Foundation/Foundation.h>

// Linux 遵循"所有皆文件"
// 目录也是一种文件
// 下面为了符合常识,文件和目录区分处理

/// 文件或目录类型
typedef enum : NSUInteger {
    PBSandBoxFileTypeNonDirectory = 0, //!< 非目录
    PBSandBoxFileTypeDirectory = 1, //!< 目录
} PBSandBoxFileType;

@interface PBSandBoxFileInfo : NSObject

@property (nonatomic, assign) long long modifyTime; //!< 文件或目录修改时间,单位s
@property (nonatomic, assign) long long size; //!< 文件或目录体积,单位B
@property (nonatomic, copy) NSString *path; //!< 文件或目录路径
@property (nonatomic, assign) PBSandBoxFileType type; //!< 文件或目录类型

@end

@interface PBSandBox : NSObject

// AD9F89C9-B544-4A63-B6D8-69B8A61BD54F
+ (NSString *)path4Home;

// /Documents
+ (NSString *)path4Documents;

// /Library
+ (NSString *)path4Library;

// /Library/Caches
+ (NSString *)path4LibraryCaches;

// /tmp/
+ (NSString *)path4Tmp;

/**
 获取指定路径[目录]下的所有[文件]或[目录]信息
 
 @param directoryPath 目录的路径
 @return 该目录下的所有文件或目录的信息
 */
+ (NSArray *)fileOrDirectoryInfosAboutContentsOfDirectoryAtPath:(NSString *)directoryPath;

/**
 获取指定路径的[文件]或[目录]信息
 
 @param fileOrDirectoryPath 文件或目录的路径
 @return 该路径的文件或目录信息
 */
+ (PBSandBoxFileInfo *)fileOrDirectoryInfoAtPath:(NSString *)fileOrDirectoryPath;

/**
 删除指定路径[目录]下的所有[文件]或[目录]
 
 @param directoryPath 目录的路径
 @return 删除成功返回YES,否则,返回NO
 */
+ (BOOL)deleteContentsOfDirectoryAtPath:(NSString *)directoryPath;

/**
 获取指定路径的[目录]大小
 
 @param directoryPath 目录的路径
 @return 该路径的目录大小,单位B
 */
+ (long long)directorySizeAtPath:(NSString *)directoryPath;

/**
 获取指定路径的[文件]大小
 
 @param filePath 文件的路径
 @return 该路径的文件大小,单位B
 */
+ (long long)fileSizeAtPath:(NSString *)filePath;

@end
