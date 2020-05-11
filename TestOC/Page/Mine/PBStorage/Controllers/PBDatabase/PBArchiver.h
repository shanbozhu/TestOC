//
//  PBArchiver.h
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/17.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

// 继承该类的子类都能够自动支持归解档操作

/**
    归档
 *<=====>NSData
    解档
           NSUTF8StringEncoding          NSJSONSerialization
 NSString<======================>NSData<=====================>NSDictionary
           NSUTF8StringEncoding          NSJSONSerialization
 */

@interface PBArchiver : NSObject<NSCoding>

/**
 归档:将任意类型对象归档为二进制数据
 
 @param obj 任意类型对象
 @param key 任意类型对象对应的key值
 @return 归档后的二进制数据
 */
+ (NSData *)dataWithObject:(id)obj key:(NSString *)key;

/**
 解档:将二进制数据解档为任意类型对象
 
 @param data 二进制数据
 @param key 任意类型对象对应的key值
 @return 解档后的任意类型对象
 */
+ (id)objectWithData:(NSData *)data key:(NSString *)key;

/**
 归档:将多个任意类型对象归档为二进制数据
 
 @param objs 多个任意类型对象
 @param keys 多个任意类型对象对应的key值
 @return 归档后的二进制数据
 */
+ (NSData *)dataWithObjects:(NSArray *)objs keys:(NSArray *)keys;

/**
 解档:将二进制数据解档为多个任意类型对象
 
 @param data 二进制数据
 @param keys 多个任意类型对象对应的key值
 @return 解档后的多个任意类型对象
 */
+ (NSArray *)objectsWithData:(NSData *)data keys:(NSArray *)keys;

@end
