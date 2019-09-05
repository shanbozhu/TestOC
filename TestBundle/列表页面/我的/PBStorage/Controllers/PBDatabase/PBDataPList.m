//
//  PBDataPList.m
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/18.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBDataPList.h"
#import "PBSandBox.h"
#import <pthread.h>
#import "PBDatabase.h"

@interface PBDataPList () {
    pthread_rwlock_t _lock;
}

@property (nonatomic, copy) NSString *filePath;

@end

// 属性列表文件的相对路径
#define DATAPLISTFILEPATH @"/Documents/myplist.plist"

static id sharedDataPList = nil;

@implementation PBDataPList

#pragma mark - 单例
+ (id)sharedDataPList {
    if (sharedDataPList == nil) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            sharedDataPList = [[self alloc]init];
        });
    }
    return sharedDataPList;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedDataPList = [super allocWithZone:zone];
    });
    return sharedDataPList;
}

- (id)init {
    if (self = [super init]) {
        pthread_rwlock_init(&_lock, NULL);
        // 文件路径
        self.filePath = [PBSandBox absolutePathWithRelativePath:DATAPLISTFILEPATH];
    }
    return self;
}

#pragma mark - 操作
- (void)setValue:(id)value forKey:(NSString *)key {
    pthread_rwlock_wrlock(&_lock);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:self.filePath];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }
    NSData *data = [PBArchiver dataWithObject:value key:key];
    [dict setValue:data forKey:key];
    [dict writeToFile:self.filePath atomically:YES]; // 自动创建父目录,不会覆盖已有目录
    pthread_rwlock_unlock(&_lock);
}

- (void)removeObjectForKey:(NSString *)defaultName {
    pthread_rwlock_wrlock(&_lock);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:self.filePath];
    [dict removeObjectForKey:defaultName];
    [dict writeToFile:self.filePath atomically:YES];
    pthread_rwlock_unlock(&_lock);
}

- (id)valueForKey:(NSString *)key {
    pthread_rwlock_rdlock(&_lock);
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:self.filePath];
    NSData *data = dict[key];
    pthread_rwlock_unlock(&_lock);
    return [PBArchiver objectWithData:data key:key];
}

- (void)removeAllObjects {
    pthread_rwlock_wrlock(&_lock);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:self.filePath];
    [dict removeAllObjects];
    [dict writeToFile:self.filePath atomically:YES];
    pthread_rwlock_unlock(&_lock);
}

- (void)dealloc {
    pthread_rwlock_destroy(&_lock);
    NSLog(@"PBDataPList对象被释放了");
}

@end
