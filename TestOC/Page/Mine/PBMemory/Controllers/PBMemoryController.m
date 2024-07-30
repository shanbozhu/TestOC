//
//  PBMemoryController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBMemoryController.h"
#import "PBMemoryListController.h"
#import "PBMemoryListMRCController.h"

/**
 语言：
 1.编译型语言：OC、Swift等。编译成机器语言，操作系统可以直接执行可执行文件。程序自上而下逐行编译，主函数开始执行。
 2.解释型语言(脚本语言)：Python、JavaScript等。解释成中间语言，操作系统需要安装对应虚拟机执行可执行文件。程序自上而下逐行解释、执行。
 
 动态语言、静态语言
 强类型语言、弱类型语言
 
 编辑 --> 编译/解释 --> 执行/调试
 IDE(集成开发环境)：
 1.代码提示
 2.代码调试
 2.1.单步执行：step over、单步执行进入：step into、执行完当前函数：step out、继续执行：continue program execution
 2.2.控制台、变量、堆栈。
 
 虚拟机(解释器)：
 Python：安装python。IDE：PyCharm
 Shell：安装bash。IDE：VSCode + bashdb
 JavaScript：安装node.js或浏览器。IDE：WebStorm
 TypeScript：安装typescript或ts-node。IDE：WebStorm
 Java：安装JDK。IDE：IDEA
 
 编译包括：
 预处理 --> 编译 --> 汇编 --> 链接
 
 预处理：对源文件进行处理，生成中间文件。主要进行文件包含和宏替换
 编译：对中间文件进行处理，生成汇编文件
 汇编：对汇编文件进行处理，生成目标文件
 链接：对目标文件进行处理，生成可执行文件。目标文件是相对地址，可执行文件是绝对地址
 
 浏览器内核：
 WebKit(WebCore和JavaScriptCore) --------> Safari
                                     |
                   BLink(WebCore和V8) --------> Chrome
 */

/**
 程序是符合[语法]的[数据结构]加[算法]。本质是【通过对象调用方法处理变量】。
 
 语法：让编译器或解释器识别
 数据结构：数据在内存中的存储结构。就是数据类型
 算法：具体使用场景。网络 + UI(文字、图片、音频、视频) + 文件(文本文件、二进制文件：例如数据库文件)
 
 字符：数字、符号、英文字母
 标识符(变量名、函数名、类名)：数字、下划线、英文字母，且开头只能是下划线、英文字母
 
 帕斯卡命名法：每个单词的首字母大写
 驼峰命名法：第一个单词首字母小写，其余单词首字母大写
 蛇形命名法：每个单词的首字母小写，采用下划线拼接
 
 数据类型：(基本类型、对象类型)
 基本类型：
 int(整型%d)
 unsigned int(无符号整型%u)
 short(短整型%hd)
 long(长整型%ld)
 long long(长长整型%lld)
 float(单精度浮点型%f)
 double(双精度浮点型%lf)
 long double(长双精度浮点型%llf)
 char(字符型%c)
 bool(布尔型%d)
 enum(枚举型%d)
 对象类型：
 string(字符串)：用""或''表示
 array(数组)：数据组合，索引遍历。又叫list，列表。用[]表示
 tuple(元组)：不可变数组。用(,)表示，()可省略
 dictionary(字典)：键值对组合，键遍历。用{}表示
 set(集合)：无序不重复数据组合。用{}表示
 struct(结构体)：数据组合，点语法遍历
 class(类)：点语法遍历
 */

/**
 数学里面的函数如下：
 y = f(x)，x为自变量，f为解析式，y为返回值
 
 程序里面的函数如下：
 返回类型 函数名(形参类型 形参名);
 
 override：覆盖。子类与父类函数名相同，形参类型相同
 overwrite：重写。子类与父类函数名相同，形参类型不同
 overload：重载。同一类中函数名相同，形参类型不同
 */

/**
 声明
 定义(等于声明加初始化)
 调用
 
 1.定义方法：new/alloc一个对象。申请内存空间
 // oc 空格中括号
 A *a = [[A alloc] init]; // 定义该类对象，返回对象地址
 
 // swift 点小括号
 A a = new A.init();
 A a = new A(); // init可省略
 A a = A(); // new可省略。自动调用init构造方法
 
 2.释放方法：del/release
 
 3.构造方法：构造时调用的方法。
 init;
 
 4.析构方法：析构时调用的方法。
 // oc
 dealloc;
 
 // swift
 deinit;
 */

/**
 // c、oc、swift调用
 
 // c
 int sum(int a, int b) {}
 sum(3, 4);
 
 // oc
 - (NSInteger)sumWithA:(NSInteger)a b:(NSInteger)b {}
 [o sumWithA:3 b:4];
 
 // swift
 // "a a: Int"第一个a是标签，第二个a是变量
 func sum(a a: Int, b b: Int) -> Int {}
 o.sum(a: 3, b: 4)
 // 不写标签，标签与变量同名
 fun sum(a: Int, b: Int) -> Int {}
 o.sum(a: 3, b: 4)
 // "_"取消标签
 func sum(_ a: Int, b b: Int) -> Int {}
 o.sum(3, b: 4)
 */

/**
  --------------------
 |应用程序              |
  --------------------              ------------------------
  --------------------             |应用编程接口(API)         |
 |操作系统              | --------> |内核函数(kernel function) |
  --------------------             |驱动程序(driver)          |
  --------------------              ------------------------
 |硬件                 |
  --------------------
 
 驱动程序、内核函数：C/C++语言编写
 应用程序接口：
 1.OC编写，主要有Foundation、UIKit等框架/库
 2.Python编写，主要有sys、urllib等框架/库
 
 静态库(.a)：编译时链接，编译时需要指定库路径
 动态库(.so)：执行时链接，编译、执行时均需要指定库路径
 */

/**
 内存分布：
 kernel ---> 内核区
 main
 stack ----> 栈区：存储局部变量
 预留区
 heap -----> 堆区：存储malloc等分配的需要手动内存管理或支持自动内存管理的变量
 bss ------> 全局区：bss段存储未初始化和初始化为0的全局变量和静态变量
 data -----> 全局区：data段存储初始化为非0的全局变量和静态变量
 rodata ---> 常量区：存储字符串和const修饰的常量
 text------> 代码区：存储函数体的二进制代码
 
 函数结束，栈消失，局部变量被释放
 
 局部变量作用域：从定义位置开始到包含它的第一个右大括号结束
 局部变量生命期：从定义位置开始到函数结束
 全局变量作用域：从定义位置开始到当前文件结束
 全局变量生命期：从定义位置开始到程序结束
 
 全局变量和函数可以重声明，不能重定义；局部变量既不能重声明，也不能重定义。
 面向对象全局变量不能重复符号链接
 
 static修饰全局变量限制全局变量作用域
 static修饰局部变量延长局部变量生命期
 static修饰函数限制函数作用域
 inline修饰内联函数，相当于宏替换函数体，允许在头文件中定义。一般与static结合使用，如static inline
 
 const修饰后面常量。常量：一旦赋值不可修改。常量又叫只读变量
 extern外部函数声明、外部变量声明
 break跳出当前循环，跳出switch判断体
 continue继续下次循环
 return函数结束，向主调函数返回空
 exit程序结束，向系统返回空
 
 访问控制
 private：当前类中访问
 fileprivate：当前文件中访问
 protected：当前类和子类中访问
 internal：当前框架中访问(Swift默认)
 public：其他类中访问(可以跨框架)
 
 时间戳：格林尼治时间1970年01月01日00时00分00秒(北京时间1970年01月01日08时00分00秒)开始至现在的总秒数。
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
