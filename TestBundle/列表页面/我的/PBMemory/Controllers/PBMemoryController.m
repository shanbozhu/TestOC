//
//  PBMemoryController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBMemoryController.h"
#import "PBMemoryListController.h"
#import "PBMemoryListMRCController.h"

/**
 编辑 --> 编译 --> 执行

 编译包括:
 预处理 --> 编译 --> 汇编 --> 链接

 预处理:对源文件进行处理,生成中间文件.主要进行文件包含和宏替换
 编译:对中间文件进行处理,生成汇编文件
 汇编:对汇编文件进行处理,生成目标文件
 链接:对目标文件进行处理,生成可执行文件.目标文件是相对地址,可执行文件是绝对地址
 */

/**
 学习历程:
 
 程序是符合[语法]的[数据结构]加[算法].本质是处理变量.
           |        |       |
           |        |        ---------
           |        |                 |
           V        V                 V
        控制语句   数据类型 + 数据运算   UI控件 + 网络 + 多线程 + 数据库
 
 1.变量定义
 数据类型:整型(short、int、long、long long)、浮点型(float、double、long double)、字符串、数组、字典、集合
 数据运算:算术运算(+、-、*、/、%、**)、比较运算(>、>=、<、<=、==)、逻辑运算(!、&&、||)、赋值运算(=)
 控制语句:判断(if语句、if/else语句、if/else if/else语句、case语句)、循环(for语句、while语句、do/while语句)
 2.函数定义
 */

/**
 数学里面的函数如下:
 y = f(x),x为自变量,f为解析式,y为返回值

 程序里面的函数如下:
 返回值类型 函数名 (形参类型 形参名);

 override:覆盖.子类与父类函数名相同,形参类型相同
 overwrite:重写.子类与父类函数名相同,形参类型不同
 overload:重载.同一类中函数名相同,形参类型不同
 */

/**
  应用程序
  --------------------
 |API                 |
 |系统调用(system call) |
 |内核函数(kernel)      |
 |驱动程序              |
  --------------------
  硬件
 */

/**
 内存分布:
 kernel ---> 内核区
 main
 stack ----> 栈区:存储局部变量
 预留区
 heap -----> 堆区:存储malloc等分配的需要手动内存管理或支持自动内存管理的变量
 bss ------> 全局区:bss段存储未初始化和初始化为0的全局变量和静态变量
 data -----> 全局区:data段存储初始化为非0的全局变量和静态变量
 rodata ---> 常量区:存储字符串和const修饰的只读变量
 text------> 代码区:存储函数体的二进制代码
 
 局部变量作用域:从定义位置开始到包含它的第一个右大括号结束
 局部变量生命期:从定义位置开始到函数结束
 全局变量作用域:从定义位置开始到当前文件结束
 全局变量生命期:从定义位置开始到程序结束
 
 全局变量和函数可以重声明,不能重定义;局部变量既不能重声明,也不能重定义.
 面向对象全局变量不能重复符号链接
 
 static修饰全局变量限制全局变量作用域
 static修饰局部变量延长局部变量生命期
 static修饰函数限制函数作用域
 
 const修饰后面只读变量.只读变量:一旦赋值不可修改
 extern导入外部变量函数声明
 break跳出当前循环,跳出switch判断体
 continue继续下次循环
 return函数结束,向主调函数返回空
 exit程序结束,向系统返回空
 */

@interface PBMemoryController ()

@end

@implementation PBMemoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 点我ARC
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(100, 200, ([UIScreen mainScreen].bounds.size.width-100)/2, 50);
    [btn setTitle:@"点我ARC" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor lightGrayColor];
    btn.tag = 0;
    
    // 点我MRC
    UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:oneBtn];
    oneBtn.frame = CGRectMake(100, 300, ([UIScreen mainScreen].bounds.size.width-100)/2, 50);
    [oneBtn setTitle:@"点我MRC" forState:UIControlStateNormal];
    [oneBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [oneBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    oneBtn.backgroundColor = [UIColor lightGrayColor];
    oneBtn.tag = 1;
}

- (void)btnClick:(UIButton *)btn {
    if (btn.tag == 0) {
        // ARC
        PBMemoryListController *testListController = [[PBMemoryListController alloc]init];
        testListController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    } else {
#ifdef OPENMRC
        // MRC
        PBMemoryListMRCController *testListMRCController = [[PBMemoryListMRCController alloc]init];
        testListMRCController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testListMRCController animated:YES];
        testListMRCController.view.backgroundColor = [UIColor whiteColor];
        
        [testListMRCController release];
#endif
    }
}

@end
