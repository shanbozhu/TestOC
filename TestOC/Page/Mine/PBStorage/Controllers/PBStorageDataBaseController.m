//
//  PBStorageDataBaseController.m
//  TestOC
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

@property (nonatomic, strong) FMDatabase *db;

@end

/**
 ascending order：升序
 descending order：降序
 
 SELECT：选择、查询
 
 聚合查询中的非聚合字段必须出现在group by中
 
 查询 所有列 来自 学生表 在那儿 分数大于等于80
 select * from students where score >= 80
 查询 score列的平均值 别名 average 来自 学生表 在那儿 性别为男性
 select avg(score) average from students where gender = 'm';
 
 // SQL简介
 SQL：Structured Query Language 结构化查询语言
 
 CSV文件：逗号分隔值文件
 id,name,gender,score
 1,小明,M,90
 2,小红,F,95
 3,小军,M,88
 4,小丽,F,88
 
 主流关系数据库
 1.商用数据库，例如：Oracle、SQL Server、DB2等；
 2.开源数据库，例如：MySQL、PostgreSQL等；
 3.桌面数据库，以微软Access为代表，适合桌面应用程序使用；
 4.嵌入式数据库，以Sqlite为代表，适合手机应用和桌面程序。
 
 基本查询
 
 -- 查询students表的所有数据
 SELECT * FROM students;
 
 -- 计算100+200
 SELECT 100+200;
 
 条件查询
 
 -- 按AND条件查询students:
 SELECT * FROM students WHERE score >= 80 AND gender = 'M';
 
 -- 按OR条件查询students:
 SELECT * FROM students WHERE score >= 80 OR gender = 'M';
 
 -- 按NOT条件查询students:
 SELECT * FROM students WHERE NOT score = 80;
 等价于
 SELECT * FROM students WHERE score <> 80;
 因此，NOT查询不是很常用。
 
 -- gender是非空
 SELECT * FROM students WHERE gender is not null;
 
 -- gender是空
 SELECT * FROM students WHERE gender is null;
 
 投影查询
 
 -- 使用投影查询
 SELECT id, score, name FROM students;
 
 -- 使用投影查询，并将列名重命名：
 SELECT id, score points, name FROM students;
 等价于
 SELECT id, score as points, name FROM students;
 
 as：作为、别名
 
 -- 使用投影查询+WHERE条件：
 SELECT id, score points, name FROM students WHERE gender = 'M';
 
 排序
 
 -- 按score从低到高:
 SELECT id, name, gender, score FROM students ORDER BY score;
 等价于
 SELECT id, name, gender, score FROM students ORDER BY score ASC;
 
 -- 按score从高到低:
 SELECT id, name, gender, score FROM students ORDER BY score DESC;
 
 -- 按score降序，如果遇到score相同，在按照gender升序:
 SELECT id, name, gender, score FROM students ORDER BY score DESC, gender ASC;
 
 分页查询
 
 -- 查询第1页:
 -- 从偏移量0开始，最多查询3条记录
 SELECT id, name, gender, score
 FROM students
 ORDER BY score DESC
 LIMIT 3 OFFSET 0;
 
 -- 查询第2页:
 SELECT id, name, gender, score
 FROM students
 ORDER BY score DESC
 LIMIT 3 OFFSET 3;
 
 -- 查询第3页:
 SELECT id, name, gender, score
 FROM students
 ORDER BY score DESC
 LIMIT 3 OFFSET 6;
 
 -- 查询第4页:
 SELECT id, name, gender, score
 FROM students
 ORDER BY score DESC
 LIMIT 3 OFFSET 9;
 
 LIMIT：总是设定为pageSize
 OFFSET：计算公式为pageSize * (pageIndex - 1)
 
 OFFSET是可选的，如果只写LIMIT 15，那么相当于LIMIT 15 OFFSET 0
 
 聚合查询
 
 -- 使用聚合查询:
 SELECT COUNT(*) FROM students;
 
 -- 使用聚合查询并设置结果集的列名为num:
 SELECT COUNT(*) num FROM students;
 
 COUNT(*)和COUNT(id)实际上是一样的效果。
 
 -- 使用聚合查询并设置WHERE条件:
 SELECT COUNT(*) boys FROM students WHERE gender = 'M';
 
 函数    说明
 COUNT  计算某一列的行数
 SUM    计算某一列的合计值，该列必须为数值类型
 AVG    计算某一列的平均值，该列必须为数值类型
 MAX    计算某一列的最大值
 MIN    计算某一列的最小值
 
 -- 使用聚合查询计算男生平均成绩:
 SELECT AVG(score) average FROM students WHERE gender = 'M';
 */














//@"select * from students order by sid ASC"; // 升序：越来越大
//@"select * from students order by sid DESC"; // 降序：越来越小

// 创建表
#define kCreateTable @"create table if not exists students (sid TEXT, name TEXT)"
// 增加记录
#define kInsert @"insert into students (sid, name) values (?, ?)"
// 删除记录
#define kDelete @"delete from students where sid = ?"
// 修改记录
#define kUpdate @"update students set name = '阿祖' where sid = ?"
// 查找记录
#define kSelect @"select * from students where sid = ?"

// 添加表字段
#define kAddColumn @"alter table students add column %@ TEXT"

// 重命名表
#define kRename @"alter table students rename to tmp"
// 复制表
#define kCopy @"insert into students select sid, name from tmp"
// 删除表
#define kDrop @"drop table tmp"

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
    
    [self initData];
}

- (void)initData {
    // 测试数据
    self.testSid = @"952";
    self.testName = @"唐";
    self.testColumn = @"sex";
    
    {
        // 指定路径创建文件
        self.filePath = [PBSandBox absolutePathWithRelativePath:@"/Documents/PBStorage/test.db"];
        [PBSandBox createFileAtPath:self.filePath];
        self.db = [FMDatabase databaseWithPath:self.filePath];
        
        // 创建表
        [self createTable];
    }
}

// 创建表
- (void)createTable {
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    if ([self.db executeUpdate:kCreateTable]) {
        NSLog(@"在数据库文件中创建表成功"); // 表名为students,含有两个表字段分别为sid和name
    }
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 增加
- (void)insert:(UIButton *)btn {
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    if ([self.db executeUpdate:kInsert, self.testSid, self.testName]) {
        NSLog(@"增加表中的一条或多条记录成功");
    }
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 删除
- (void)delete:(UIButton *)btn {
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    if ([self.db executeUpdate:kDelete, self.testSid]) {
        NSLog(@"删除表中的一条或多条记录成功");
    }
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 修改
- (void)update:(UIButton *)btn {
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    if ([self.db executeUpdate:kUpdate, self.testSid]) {
        NSLog(@"修改表中的一条或多条记录成功");
    }
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 查找
- (void)select:(UIButton *)btn {
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    FMResultSet *result = [self.db executeQuery:kSelect, self.testSid];
    while ([result next]) {
        NSString *sid = [result stringForColumn:@"sid"];
        NSString *name = [result stringForColumn:@"name"];
        NSLog(@"sid = %@, name = %@", sid, name);
    }
    NSLog(@"查找表中的一条或多条记录成功");
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 添加表字段
- (void)alter:(UIButton *)btn {
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    if (![self.db columnExists:self.testColumn inTableWithName:@"students"]) {
        NSString *sql = [NSString stringWithFormat:kAddColumn, self.testColumn];
        if ([self.db executeUpdate:sql]) {
            NSLog(@"添加表字段成功");
        }
    } else {
        NSLog(@"添加表字段失败,表中已经含有要添加的字段");
    }
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 重命名表
- (void)rename:(UIButton *)btn {
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    if ([self.db tableExists:@"students"]) {
        if ([self.db executeUpdate:kRename]) {
            NSLog(@"重命名表成功");
        }
    } else {
        NSLog(@"重命名表失败,不存在需要重命名的表名");
    }
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 复制表
- (void)copy:(UIButton *)btn {
    // 创建表
    [self createTable];
    
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    if ([self.db executeUpdate:kCopy]) {
        NSLog(@"复制表成功");
    }
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

// 删除表
- (void)drop:(UIButton *)btn {
    if (![self.db open]) {
        NSLog(@"打开数据库文件失败");
    }
    if ([self.db tableExists:@"tmp"]) {
        NSString *sql = kDrop;
        if ([self.db executeUpdate:sql]) {
            NSLog(@"删除表成功");
        }
    } else {
        NSLog(@"删除表失败,没有需要删除的表");
    }
    if (![self.db close]) {
        NSLog(@"关闭数据库文件失败");
    }
}

- (void)dealloc {
    NSLog(@"PBStorageDataBaseController对象被释放了");
}

@end
