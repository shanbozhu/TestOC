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
 主键：唯一标识一条记录，不能有重复的，不允许为空。
 注意：数据库的一张表中可以存储相同的记录，因为决定记录唯一性的是主键，主键一般不作为真正的记录。
 参考文档：
 SQLite学习手册 - 自增与主键 https://blog.csdn.net/ghlfllz/article/details/21284627
 
 SELECT：选择、查询
 
 聚合查询中的非聚合字段必须出现在group by中
 
 查询 所有列 来自 学生表 在那儿 分数大于等于80
 select * from students where score >= 80;
 
 查询 score列的平均值 作为 average 来自 学生表 在那儿 性别为男性
 select avg(score) average from students where gender = 'm';
 
 查询 class_id gender count(*)所有列的行数 作为 num 来自 学生表 在那儿 分组通过 class_id 和 gender
 select class_id, gender, count(*) num from students group by class_id, gender;
 执行效果如下：
 原始表：
 id    class_id    name    gender    score
 1    1    小明    M    90
 2    1    小红    F    95
 3    1    小军    M    88
 4    1    小米    F    73
 5    2    小白    F    81
 6    2    小兵    M    55
 7    2    小林    M    85
 8    3    小新    F    91
 9    3    小王    M    89
 10    3    小丽    F    85
 
 结果集：
 class_id    gender    num
 1    M    2
 1    F    2
 2    F    1
 2    M    2
 3    F    2
 3    M    1
 
 COUNT(1)和COUNT(*)在大多数数据库系统中是等价的，它们都会返回相同的结果。使用COUNT(1)而不是COUNT(*)有时候可以在某些数据库系统中提供更好的性能。
 
 // SQL简介
 SQL：Structured Query Language 结构化查询语言
 
 CSV文件：逗号分隔值文件
 id,name,gender,score
 1,小明,M,90
 2,小红,F,95
 3,小军,M,88
 4,小丽,F,88
 
 主流关系数据库
 1. 商用数据库，例如：Oracle、SQL Server、DB2等；
 2. 开源数据库，例如：MySQL、PostgreSQL等；
 3. 桌面数据库，以微软Access为代表，适合桌面应用程序使用；
 4. 嵌入式数据库，以Sqlite为代表，适合手机应用和桌面程序。
 
 **基本查询**
 
 -- 查询students表的所有数据
 SELECT * FROM students;
 
 -- 计算100+200
 SELECT 100+200;
 
 **条件查询**
 
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
 
 **投影查询**
 
 -- 使用投影查询
 SELECT id, score, name FROM students;
 
 -- 使用投影查询，并将列名重命名：
 SELECT id, score points, name FROM students;
 等价于
 SELECT id, score as points, name FROM students;
 
 as：作为、别名
 
 -- 使用投影查询+WHERE条件：
 SELECT id, score points, name FROM students WHERE gender = 'M';
 
 **排序查询**
 
 ascending order：升序
 descending order：降序
 
 -- 按score从低到高:
 SELECT id, name, gender, score FROM students ORDER BY score;
 等价于
 SELECT id, name, gender, score FROM students ORDER BY score ASC;
 
 -- 按score从高到低:
 SELECT id, name, gender, score FROM students ORDER BY score DESC;
 
 -- 按score降序，如果遇到score相同，在按照gender升序:
 SELECT id, name, gender, score FROM students ORDER BY score DESC, gender ASC;
 
 **分页查询**
 
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
 
 **聚合查询**
 
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
 
 如果我们要统计一班的学生数量，我们知道，可以用SELECT COUNT(*) num FROM students WHERE class_id = 1;。如果要继续统计二班、三班的学生数量，难道必须不断修改WHERE条件来执行SELECT语句吗？
 -- 按class_id分组:
 SELECT COUNT(*) num FROM students GROUP BY class_id;
 执行该SELECT语句时，会把class_id相同的列先分组，再分别计算，因此，得到了3行结果。
 
 但是这3行结果分别是哪三个班级的，不好看出来，所以我们可以把class_id列也放入结果集中：
 -- 按class_id分组:
 SELECT class_id, COUNT(*) num FROM students GROUP BY class_id;
 
 也可以使用多个列进行分组。例如，我们想统计各班的男生和女生人数：
 -- 按class_id, gender分组:
 SELECT class_id, gender, COUNT(*) num FROM students GROUP BY class_id, gender;
 上述查询结果集一共有6条记录，分别对应各班级的男生和女生人数。
 
 **多表查询**
 
 -- FROM students, classes:
 SELECT * FROM students, classes;
 这种一次查询两个表的数据，查询的结果也是一个二维表，它是students表和classes表的“乘积”，即students表的每一行与classes表的每一行都两两拼在一起返回。结果集的列数是students表和classes表的列数之和，行数是students表和classes表的行数之积。
 这种多表查询又称笛卡尔查询，使用笛卡尔查询时要非常小心，由于结果集是目标表的行数乘积，对两个各自有100行记录的表进行笛卡尔查询将返回1万条记录，对两个各自有1万行记录的表进行笛卡尔查询将返回1亿条记录。
 
 -- set alias:
 SELECT
     students.id sid,
     students.name,
     students.gender,
     students.score,
     classes.id cid,
     classes.name cname
 FROM students, classes;
 
 注意，多表查询时，要使用表名.列名这样的方式来引用列和设置别名，这样就避免了结果集的列名重复问题。但是，用表名.列名这种方式列举两个表的所有列实在是很麻烦，所以SQL还允许给表设置一个别名，让我们在投影查询中引用起来稍微简洁一点：
 -- set table alias:
 SELECT
     s.id sid,
     s.name,
     s.gender,
     s.score,
     c.id cid,
     c.name cname
 FROM students s, classes c;
 
 -- set where clause:
 SELECT
     s.id sid,
     s.name,
     s.gender,
     s.score,
     c.id cid,
     c.name cname
 FROM students s, classes c
 WHERE s.gender = 'M' AND c.id = 1;
 
 **连接查询**
 
 -- 选出所有学生:
 SELECT s.id, s.name, s.class_id, s.gender, s.score FROM students s;
 
 -- 选出所有学生，同时返回班级名称:
 SELECT s.id, s.name, s.class_id, c.name class_name, s.gender, s.score
 FROM students s
 INNER JOIN classes c
 ON s.class_id = c.id;
 
 -- 使用OUTER JOIN:
 SELECT s.id, s.name, s.class_id, c.name class_name, s.gender, s.score
 FROM students s
 RIGHT OUTER JOIN classes c
 ON s.class_id = c.id;
 
 -- 先增加一列class_id=5:
 INSERT INTO students (class_id, name, gender, score) values (5, '新生', 'M', 88);
 -- 使用LEFT OUTER JOIN:
 SELECT s.id, s.name, s.class_id, c.name class_name, s.gender, s.score
 FROM students s
 LEFT OUTER JOIN classes c
 ON s.class_id = c.id;
 
 -- 使用FULL OUTER JOIN:
 SELECT s.id, s.name, s.class_id, c.name class_name, s.gender, s.score
 FROM students s
 FULL OUTER JOIN classes c
 ON s.class_id = c.id;
 
 **插入数据**
 
 -- 添加一条新记录:
 INSERT INTO students (class_id, name, gender, score) VALUES (2, '大牛', 'M', 80);
 
 -- 一次性添加多条新记录:
 INSERT INTO students (class_id, name, gender, score) VALUES
   (1, '大宝', 'M', 87),
   (2, '二宝', 'M', 81),
   (3, '三宝', 'M', 83);
 
 **更新数据**
 
 -- 更新id = 1的记录:
 UPDATE students SET name = '大牛', score = 66 WHERE id = 1;
 
 -- 更新id = 5、6、7的记录:
 UPDATE students SET name = '小牛', score = 77 WHERE id >= 5 AND id <= 7;
 
 在UPDATE语句中，更新字段时可以使用表达式。例如，把所有80分以下的同学的成绩加10分：
 -- 更新score < 80的记录:
 UPDATE students SET score = score + 10 WHERE score < 80;
 
 最后，要特别小心的是，UPDATE语句可以没有WHERE条件，例如：
 -- 更新所有记录:
 UPDATE students SET score = 60;
 这时，整个表的所有记录都会被更新。
 
 **删除数据**
 
 -- 删除id = 1的记录:
 DELETE FROM students WHERE id = 1;
 
 -- 删除id = 5、6、7的记录:
 DELETE FROM students WHERE id >= 5 AND id <= 7;
 
 最后，要特别小心的是，和UPDATE类似，不带WHERE条件的DELETE语句会删除整个表的数据：
 -- 删除所有记录:
 DELETE FROM students;
 这时，整个表的所有记录都会被删除。
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
