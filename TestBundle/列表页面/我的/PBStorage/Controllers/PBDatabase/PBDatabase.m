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

@end

#define DATABASEFILENAME @"/mydb.db"

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
        NSLog(@"[PBSandBox path4Home] = %@", [PBSandBox path4Home]);
    }
    return self;
}

// 增加
- (void)setValue:(id)value forKey:(NSString *)key {
    pthread_rwlock_wrlock(&_lock);
    
    // 文件路径
    NSString *filePath = [[PBSandBox path4Documents]stringByAppendingString:DATABASEFILENAME];
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    // 连接数据库文件
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    
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
    
    if (![db executeUpdate:@"insert into myTable(key, value) values(?, ?)", key, [self.class dataWithObject:value andKey:key]]) { //字段是二进制类型必须使用?占位
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
    
    // 文件路径
    NSString *filePath = [[PBSandBox path4Documents]stringByAppendingString:DATABASEFILENAME];
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    // 连接数据库文件
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    
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
    
    // 文件路径
    NSString *filePath = [[PBSandBox path4Documents]stringByAppendingString:DATABASEFILENAME];
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    // 连接数据库文件
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    
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
    
    return [self.class objectWithData:value andKey:key];
}

// 删除所有数据
- (void)removeAllObjects {
    pthread_rwlock_wrlock(&_lock);
    
    // 文件路径
    NSString *filePath = [[PBSandBox path4Documents]stringByAppendingString:DATABASEFILENAME];
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    // 连接数据库文件
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    
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

// 归档:将任意类型对象归档为二进制数据
+ (NSData *)dataWithObject:(id)obj andKey:(NSString *)key {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:obj forKey:key];
    [archiver finishEncoding];
    return data;
}

// 解档:将二进制数据解档为任意类型对象
+ (id)objectWithData:(NSData *)data andKey:(NSString *)key {
    if (data == nil) {
        return nil;
    }
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    id obj = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    return obj;
}

- (void)dealloc {
    pthread_rwlock_destroy(&_lock);
    NSLog(@"PBDatabase对象被释放了");
}

@end
