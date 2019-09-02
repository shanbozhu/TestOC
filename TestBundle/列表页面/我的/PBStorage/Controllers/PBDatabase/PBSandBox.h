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

/// 文件类型
typedef enum : NSUInteger {
    PBSandBoxFileTypeNonDirectory = 0, //!< 非目录
    PBSandBoxFileTypeDirectory = 1, //!< 目录
} PBSandBoxFileType;

@interface PBSandBoxFileInfo : NSObject

@property (nonatomic, assign) long long modifyTime; //!< 文件修改时间,单位s
@property (nonatomic, assign) long long size; //!< 文件体积
@property (nonatomic, copy) NSString *filePath; //!< 文件路径
@property (nonatomic, assign) PBSandBoxFileType fileType; //!< 文件类型

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
 获取指定路径下的文件信息
 */
+ (PBSandBoxFileInfo *)fileInfoAtPath:(NSString *)filePath;




+ (NSArray *)fileInfosAboutContentsOfDirectoryAtPath:(NSString *)filePath;

@end
