//
//  PBStorageDataBaseController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageDataBaseController.h"
#import "YYFPSLabel.h"
#import <fmdb/FMDB.h>
#import "PBSandBox.h"
#import <pthread.h>

@interface PBStorageDataBaseController ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *testName;
@property (nonatomic, copy) NSString *testSid;
@property (nonatomic, copy) NSString *testColumn;

@end

@implementation PBStorageDataBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"[PBSandBox path4Home] = %@", [PBSandBox path4Home]);
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    for (int i = 0;  i < 8; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [scrollView addSubview:btn];
        btn.frame = CGRectMake(20, 20+(40+20)*i, [UIScreen mainScreen].bounds.size.width-40, 40);
        btn.backgroundColor = [UIColor lightGrayColor];
        if (i == 0) {
            [btn setTitle:@"insert(增)" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(insert:) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 1) {
            [btn setTitle:@"delete(删)" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 2) {
            [btn setTitle:@"update(改)" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 3) {
            [btn setTitle:@"select(查)" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 4) {
            [btn setTitle:@"alter(添加表字段)" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(alter:) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 5) {
            [btn setTitle:@"rename(重命名表)" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(rename:) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 6) {
            [btn setTitle:@"copy(复制表)" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(copy:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [btn setTitle:@"drop(删除表)" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(drop:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    if (CGRectGetMaxY([[scrollView.subviews lastObject] frame]) > [UIScreen mainScreen].bounds.size.height) {
        scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY([[scrollView.subviews lastObject] frame]));
    }
    
    {
        // 测试数据
        self.testSid = @"952";
        self.testName = @"唐";
        self.testColumn = @"sex";
    }
    
    {
        // 指定路径创建文件
        self.filePath = [PBSandBox absolutePathWithRelativePath:@"/Documents/PBStorage/test.db"];
        [PBSandBox createFileAtPath:self.filePath];
        
        // 创建表
        [self createTable];
    }
}

// 创建表
- (void)createTable {
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if ([db executeUpdate:@"create table if not exists students(sid TEXT, name TEXT)"]) {
        NSLog(@"在数据库文件中创建表成功"); // 表名为students,含有两个表字段分别为sid和name
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 增加
- (void)insert:(UIButton *)btn {
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if ([db executeUpdate:@"insert into students(sid, name) values(?, ?)", self.testSid, self.testName]) {
        NSLog(@"增加表中的一条或多条记录成功");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 删除
- (void)delete:(UIButton *)btn {
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if ([db executeUpdate:@"delete from students where sid = ?", self.testSid]) {
        NSLog(@"删除表中的一条或多条记录成功");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 修改
- (void)update:(UIButton *)btn {
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if ([db executeUpdate:@"update students set name = '阿祖', sid = '1' where sid = ?", self.testSid]) {
        NSLog(@"修改表中的一条或多条记录成功");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 查找
- (void)select:(UIButton *)btn {
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    //NSString *sql = @"select * from students order by sid ASC"; // 正向输出
    //NSString *sql = @"select * from students order by sid DESC"; // 反向输出
    //NSString *sql = @"select name from students where sid = '952'";
    //NSString *sql = @"select * from students where sid = '952'";
    FMResultSet *result = [db executeQuery:@"select * from students where sid = ?", self.testSid];
    while ([result next]) {
        NSString *sid = [result stringForColumn:@"sid"];
        NSString *name = [result stringForColumn:@"name"];
        NSLog(@"sid = %@, name = %@", sid, name);
    }
    NSLog(@"查找表中的一条或多条记录成功");
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 添加表字段
- (void)alter:(UIButton *)btn {
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if (![db columnExists:self.testColumn inTableWithName:@"students"]) {
        NSString *sql = [NSString stringWithFormat:@"alter table students add column %@ TEXT", self.testColumn];
        if ([db executeUpdate:sql]) {
            NSLog(@"添加表字段成功");
        }
    } else {
        NSLog(@"添加表字段失败,表中已经含有要添加的字段");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 重命名表
- (void)rename:(UIButton *)btn {
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if ([db tableExists:@"students"]) {
        if ([db executeUpdate:@"alter table students rename to tmp"]) {
            NSLog(@"重命名表成功");
        }
    } else {
        NSLog(@"重命名表失败,不存在需要重命名的表名");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 复制表
- (void)copy:(UIButton *)btn {
    // 创建表
    [self createTable];
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if ([db executeUpdate:@"insert into students select sid, name from tmp"]) {
        NSLog(@"复制表成功");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 删除表
- (void)drop:(UIButton *)btn {
    FMDatabase *db = [FMDatabase databaseWithPath:self.filePath];
    if (![db open]) {
        NSLog(@"打开数据库文件失败");
    }
    
    if ([db tableExists:@"tmp"]) {
        NSString *sql = @"drop table tmp";
        if ([db executeUpdate:sql]) {
            NSLog(@"删除表成功");
        }
    } else {
        NSLog(@"删除表失败,没有需要删除的表");
    }
    
    if (![db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

- (void)dealloc {
    NSLog(@"PBStorageDataBaseController对象被释放了");
}

@end
