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

@interface PBDatabase ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

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
        // 指定路径创建文件
        self.filePath = [PBSandBox absolutePathWithRelativePath:DATABASEFILEPATH];
        [PBSandBox createFileAtPath:self.filePath];
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.filePath]; // 无法自动创建父目录
        
        // 创建表
        [self createTable];
    }
    return self;
}

#pragma mark - 操作
- (void)createTable {
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if (![db executeUpdate:@"create table if not exists myTable(key TEXT, value BLOB)"]) {
            NSLog(@"在数据库文件中创建表失败");
        }
    }];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *result = [db executeQuery:@"select * from myTable where key = ?", key];
        while ([result next]) {
            if (![db executeUpdate:@"delete from myTable where key = ?", key]) {
                NSLog(@"删除表中的一条或多条记录失败");
            }
        }
        if (![db executeUpdate:@"insert into myTable(key, value) values(?, ?)", key, [PBArchiver dataWithObject:value key:key]]) {
            NSLog(@"增加表中的一条或多条记录失败");
        }
    }];
}

- (void)removeObjectForKey:(NSString *)defaultName {
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if (![db executeUpdate:@"delete from myTable where key = ?", defaultName]) {
            NSLog(@"删除表中的一条或多条记录失败");
        }
    }];
}

- (id)valueForKey:(NSString *)key {
    __block NSData *value;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *result = [db executeQuery:@"select * from myTable where key = ?", key];
        while ([result next]) {
            value = [result dataForColumn:@"value"];
        }
    }];
    return [PBArchiver objectWithData:value key:key];
}

- (void)removeAllObjects {
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if (![db executeUpdate:@"delete from myTable"]) {
            NSLog(@"删除表中的一条或多条记录失败");
        }
    }];
}

- (void)dealloc {
    NSLog(@"PBDatabase对象被释放了");
}

@end
