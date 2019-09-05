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

@end

#define DATABASEFILEPATH @"/Documents/mydb.db"

static id sharedDatabase = nil;

@implementation PBDatabase

+ (id)sharedDatabase {
    if (sharedDatabase == nil) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            sharedDatabase = [[self alloc]init];
        });
    }
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
        // 文件路径
        self.filePath = [PBSandBox absolutePathWithRelativePath:DATABASEFILEPATH];
        [PBSandBox createFileAtPath:self.filePath];
    }
    return self;
}

// 增加
- (void)setValue:(id)value forKey:(NSString *)key {
    pthread_rwlock_wrlock(&_lock);
    
    // 连接数据库文件
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if (![db executeUpdate:@"create table if not exists myTable(key TEXT, value BLOB)"]) {
        NSLog(@"在数据库文件中创建表失败");
    }
    
    FMResultSet *result = [db executeQuery:@"select key from myTable where key = ?", key];
    if ([result next]) {
        if (![db executeUpdate:@"delete from myTable where key = ?", key]) {
            NSLog(@"删除表中的一条或多条记录失败");
        }
    }
    
    if (![db executeUpdate:@"insert into myTable(key, value) values(?, ?)", key, [PBArchiver dataWithObject:value andKey:key]]) { //字段是二进制类型必须使用?占位
        NSLog(@"增加表中的一条或多条记录失败");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
    
    pthread_rwlock_unlock(&_lock);
}

// 删除
- (void)removeObjectForKey:(NSString *)defaultName {
    pthread_rwlock_wrlock(&_lock);
    
    // 连接数据库文件
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if (![db executeUpdate:@"delete from myTable where key = ?", defaultName]) {
        NSLog(@"删除表中的一条或多条记录失败");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
    
    pthread_rwlock_unlock(&_lock);
}

// 查找
- (id)valueForKey:(NSString *)key {
    pthread_rwlock_rdlock(&_lock);
    
    // 连接数据库文件
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    NSData *value;
    
    FMResultSet *result = [db executeQuery:@"select * from myTable where key = ?", key];
    while ([result next]) {
        value = [result dataForColumn:@"value"];
    }
    //NSLog(@"查找表中的一条或多条记录失败");
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
    
    pthread_rwlock_unlock(&_lock);
    
    return [PBArchiver objectWithData:value andKey:key];
}

// 删除所有数据
- (void)removeAllObjects {
    pthread_rwlock_wrlock(&_lock);
    
    // 连接数据库文件
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if (![db executeUpdate:@"delete from myTable"]) {
        NSLog(@"删除表中的一条或多条记录失败");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
    
    pthread_rwlock_unlock(&_lock);
}

- (void)dealloc {
    pthread_rwlock_destroy(&_lock);
    NSLog(@"PBDatabase对象被释放了");
}

@end
