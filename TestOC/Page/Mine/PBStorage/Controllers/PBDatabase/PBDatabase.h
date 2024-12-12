//
//  PBDatabase.h
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBDataPList.h"
#import "PBSandBox.h"
#import "PBArchiver.h"
#import <fmdb/FMDB.h>

// 支持多线程操作
@interface PBDatabase : NSObject

+ (instancetype)sharedDatabase;

/**
 增加任意类型对象到数据库(db)文件
 
 @param value 任意类型对象，包括自定义类型
 @param key 任意类型对象对应的key值
 */
- (void)setValue:(id)value forKey:(NSString *)key;

/**
 删除任意类型对象
 
 @param defaultName 任意类型对象对应的key值
 */
- (void)removeObjectForKey:(NSString *)defaultName;

/**
 查找任意类型对象
 
 @param key 任意类型对象对应的key值
 @return 任意类型对象
 */
- (id)valueForKey:(NSString *)key;

/**
 删除所有任意类型对象
 */
- (void)removeAllObjects;

@end
