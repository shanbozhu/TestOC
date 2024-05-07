//
//  PBDataPList.m
//  TestOC
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
@property (nonatomic, strong) NSMutableDictionary *dict;

@end

// 属性列表文件的相对路径
#define DATAPLISTFILEPATH @"/Documents/PBStorage/PBStoragePlist.plist"

static id sharedDataPList = nil;

@implementation PBDataPList

#pragma mark - 单例

+ (id)sharedDataPList {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedDataPList = [[self alloc]init];
    });
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
        
        // 指定路径创建文件
        self.filePath = [PBSandBox absolutePathWithRelativePath:DATAPLISTFILEPATH];
        [PBSandBox createFileAtPath:self.filePath];
        
        self.dict = [NSMutableDictionary dictionaryWithContentsOfFile:self.filePath];
        if (!self.dict) {
            self.dict = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

#pragma mark - 操作

- (void)setValue:(id)value forKey:(NSString *)key {
    pthread_rwlock_wrlock(&_lock);
    NSData *data = [PBArchiver dataWithObject:value key:key];
    [self.dict setValue:data forKey:key];
    [self.dict writeToFile:self.filePath atomically:YES]; // 无法自动创建父目录
    pthread_rwlock_unlock(&_lock);
}

- (void)removeObjectForKey:(NSString *)defaultName {
    pthread_rwlock_wrlock(&_lock);
    [self.dict removeObjectForKey:defaultName];
    [self.dict writeToFile:self.filePath atomically:YES]; // 无法自动创建父目录
    pthread_rwlock_unlock(&_lock);
}

- (id)valueForKey:(NSString *)key {
    pthread_rwlock_rdlock(&_lock);
    NSData *data = [self.dict valueForKey:key];
    id obj = [PBArchiver objectWithData:data key:key];
    pthread_rwlock_unlock(&_lock);
    return obj;
}

- (void)removeAllObjects {
    pthread_rwlock_wrlock(&_lock);
    [self.dict removeAllObjects];
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    pthread_rwlock_unlock(&_lock);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    pthread_rwlock_destroy(&_lock);
    NSLog(@"PBDataPList对象被释放了");
}

@end
