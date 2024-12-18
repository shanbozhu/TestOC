//
//  PBDatabase.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBDatabase.h"
#import "PBSandBox.h"

@interface PBDatabase ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

// 数据库最新版本号
static const NSUInteger kLatestDatabaseVersion = 2;

#define DATABASEFILEPATH @"/Documents/PBStorage/PBStorageDb.db"

// 创建表
#define kCreateTable @"create table if not exists keyValueTable (id INTEGER primary key autoincrement, key TEXT not null, value BLOB not null)"
// 数据库升级创建表二
#define kCreateTableTwo @"create table if not exists newTable (id INTEGER primary key autoincrement, key TEXT not null, value BLOB not null)"

// 杂注 设置用户版本
#define kSetUserVersion @"PRAGMA user_version = %zd"
// 杂注 获取用户版本
#define kUserVersion @"PRAGMA user_version"

// 增加记录
#define kInsert @"insert into keyValueTable (key, value) values (?, ?)"
// 删除记录
#define kDelete @"delete from keyValueTable where key = ?"
// 修改记录
#define kUpdate @"update keyValueTable set value = ? where key = ?"
// 查找记录
#define kSelect @"select value from keyValueTable where key = ?"
// 删除所有记录
#define kDeleteAll @"delete from keyValueTable"

static id sharedDatabase = nil;

@implementation PBDatabase

#pragma mark - 单例

+ (instancetype)sharedDatabase {
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

#pragma mark - 初始化

- (id)init {
    if (self = [super init]) {
        // 指定路径创建文件
        self.filePath = [PBSandBox absolutePathWithRelativePath:DATABASEFILEPATH];
        [PBSandBox createFileAtPath:self.filePath];
        
        // 连接数据库
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.filePath]; // 无法自动创建父目录
        
        [self checkDatabaseVersion];
    }
    return self;
}

- (void)checkDatabaseVersion {
    NSUInteger version = [self versionOfDatabase];
    if (version > kLatestDatabaseVersion) {
        NSLog(@"数据库中的版本号比当前版本号高, 错误!!");
    }
    if (version < kLatestDatabaseVersion) {
        if (version == 0) { // 首次创建数据库文件
            [self initDatabase];
        } else { // 升级数据库文件
            [self upgradeDatabaseFromVersion:version];
        }
    }
}

- (void)upgradeDatabaseFromVersion:(NSUInteger)version {
    // 数据库的升级必须逐版本升级
    for (NSUInteger i = version; i < kLatestDatabaseVersion; i++) {
        NSString *aSelectorName = [NSString stringWithFormat:@"upgradeFromV%luToV%lu", i, i+1];
        SEL aSelector = NSSelectorFromString(aSelectorName);
        if ([self respondsToSelector:aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:aSelector];
#pragma clang diagnostic pop
        }
    }
}

// 老用户原先只有第一张表，升级程序后添加了第二张表
- (void)upgradeFromV1ToV2 {
    [self excuteSQLInTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:[NSString stringWithFormat:kSetUserVersion, kLatestDatabaseVersion]];
        [db executeUpdate:kCreateTableTwo];
    }];
}

// 新用户直接创建先后两个版本添加的表
- (void)initDatabase {
    [self excuteSQLInTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:[NSString stringWithFormat:kSetUserVersion, kLatestDatabaseVersion]];
        [db executeUpdate:kCreateTable]; // kLatestDatabaseVersion为1时，创建的第一张表
        [db executeUpdate:kCreateTableTwo]; // kLatestDatabaseVersion为2时，数据库升级增加创建的第二张表
    }];
}

- (NSUInteger)versionOfDatabase {
    __block NSUInteger version = 0;
    [self excuteSQLInTransaction:^(FMDatabase *db, BOOL *rollback) {
        version = [db intForQuery:kUserVersion];
    }];
    return version;
}

#pragma mark - 线程安全的数据库操作

- (void)excuteSQLInTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self.dbQueue inTransaction:block];
}

#pragma mark - 操作

- (void)setValue:(id)value forKey:(NSString *)key {
    if (!value ||
        !key) {
        return;
    }
    [self excuteSQLInTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *result = [db executeQuery:kSelect, key];
        while ([result next]) {
            [db executeUpdate:kDelete, key];
        }
        [db executeUpdate:kInsert, key, [PBArchiver dataWithObject:value key:key]];
        
        /**
        // 存在多线程问题，待解决
        while ([result next]) {
            // 如果存在，则直接更新记录
            [db executeUpdate:kUpdate, [PBArchiver dataWithObject:value key:key], key];
            return;
        }
        // 如果不存，则新增记录
        [db executeUpdate:kInsert, key, [PBArchiver dataWithObject:value key:key]];
         */
    }];
}

- (void)removeObjectForKey:(NSString *)defaultName {
    if (!defaultName) {
        return;
    }
    [self excuteSQLInTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:kDelete, defaultName];
    }];
}

- (id)valueForKey:(NSString *)key {
    if (!key) {
        return nil;
    }
    __block NSData *value;
    [self excuteSQLInTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *result = [db executeQuery:kSelect, key];
        while ([result next]) {
            value = [result dataForColumn:@"value"];
        }
    }];
    return [PBArchiver objectWithData:value key:key];
}

- (void)removeAllObjects {
    [self excuteSQLInTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:kDeleteAll];
    }];
}

#pragma mark - 生命周期

- (void)dealloc {
    NSLog(@"PBDatabase对象被释放了");
}

@end
