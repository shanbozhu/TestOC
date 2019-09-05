//
//  PBArchiver.h
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/17.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 继承该类的子类都能够自动支持归解档操作
 */

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
+ (NSData *)dataWithObject:(id)obj andKey:(NSString *)key;

/**
 解档:将二进制数据解档为任意类型对象
 
 @param data 二进制数据
 @param key 任意类型对象对应的key值
 @return 解档后的任意类型对象
 */
+ (id)objectWithData:(NSData *)data andKey:(NSString *)key;

+ (NSData *)dataWithObjects:(NSArray *)objs andKeys:(NSArray *)keys;
+ (NSArray *)objectsWithData:(NSData *)data andKeys:(NSArray *)keys;

@end
