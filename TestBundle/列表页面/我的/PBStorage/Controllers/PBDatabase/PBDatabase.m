//
//  PBDatabase.m
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBDatabase.h"
#import <fmdb/FMDB.h>
#import "PBSandBox.h"
#import <pthread.h>

@interface PBDatabase () {
    pthread_rwlock_t _lock;
}

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) FMDatabase *db;

@end

#define DATABASEFILEPATH @"/Documents/PBStorage/PBStorageDb.db"

static id sharedDatabase = nil;

@implementation PBDatabase

#pragma mark - 单例
+ (id)sharedDatabase {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedDatabase = [[self alloc]init];
    });
    return sharedDatabase;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedDatabase = [super allocWithZone:zone];
    });
    return sharedDatabase;
}

- (id)init {
    if (self = [super init]) {
        pthread_rwlock_init(&_lock, NULL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        // 指定路径创建文件
        self.filePath = [PBSandBox absolutePathWithRelativePath:DATABASEFILEPATH];
        [PBSandBox createFileAtPath:self.filePath];
        self.db = [FMDatabase databaseWithPath:self.filePath]; // 无法自动创建父目录
        
        // 创建表
        [self createTable];
    }
    return self;
}

- (void)applicationDidEnterBackground {
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

#pragma mark - 操作
- (void)createTable {
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    if (![self.db executeUpdate:@"create table if not exists myTable(key TEXT, value BLOB)"]) {
        NSLog(@"在数据库文件中创建表失败");
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    pthread_rwlock_wrlock(&_lock);
    
    FMResultSet *result = [self.db executeQuery:@"select * from myTable where key = ?", key];
    while ([result next]) {
        if (![self.db executeUpdate:@"delete from myTable where key = ?", key]) {
            NSLog(@"删除表中的一条或多条记录失败");
        }
    }
    if (![self.db executeUpdate:@"insert into myTable(key, value) values(?, ?)", key, [PBArchiver dataWithObject:value key:key]]) {
        NSLog(@"增加表中的一条或多条记录失败");
    }
    
    pthread_rwlock_unlock(&_lock);
}

- (void)removeObjectForKey:(NSString *)defaultName {
    pthread_rwlock_wrlock(&_lock);
    
    if (![self.db executeUpdate:@"delete from myTable where key = ?", defaultName]) {
        NSLog(@"删除表中的一条或多条记录失败");
    }
    
    pthread_rwlock_unlock(&_lock);
}

- (id)valueForKey:(NSString *)key {
    pthread_rwlock_rdlock(&_lock);
    
    NSData *value;
    FMResultSet *result = [self.db executeQuery:@"select * from myTable where key = ?", key];
    while ([result next]) {
        value = [result dataForColumn:@"value"];
    }
    
    pthread_rwlock_unlock(&_lock);
    return [PBArchiver objectWithData:value key:key];
}

- (void)removeAllObjects {
    pthread_rwlock_wrlock(&_lock);
    
    if (![self.db executeUpdate:@"delete from myTable"]) {
        NSLog(@"删除表中的一条或多条记录失败");
    }
    
    pthread_rwlock_unlock(&_lock);
}

- (void)dealloc {
    pthread_rwlock_destroy(&_lock);
    NSLog(@"PBDatabase对象被释放了");
}

@end
