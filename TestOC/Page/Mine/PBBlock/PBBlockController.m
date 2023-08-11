//
//  PBBlockController.m
//  TestOC
//
//  Created by shanbo on 2023/8/7.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBBlockController.h"

typedef NSInteger(^block_t)(NSInteger a, NSInteger b); // block类型定义

@interface PBBlockController ()

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSInteger(^block)(NSInteger a, NSInteger b); // block作为属性

@end

@implementation PBBlockController

# pragma mark - JavaScript

/**
 // 匿名函数
 var x = function (a, b) {
     return a + b
 };
 console.log(x(1, 2));
 
 var x = (a, b) => {
     return a + b
 };
 console.log(x(1, 2));
 
 // 匿名函数自调用
 var x = (function (a, b) {
      return a + b
  })(1, 2);
 console.log(x)
 
 // 嵌套函数
 function outerFunction() {
     var counter = 0;
     function innerFunction() {
         return counter += 1;
     }
     return innerFunction;
 }
 var add = outerFunction();
 console.log(add());
 console.log(add());
 console.log(add());
 */

# pragma mark - Swift

/**
 // 闭包
 let closure: (Int, Int) -> Int = { (a: Int, b: Int) -> Int in
     return a + b
 }
 print(closure(1, 2))
 
 // 闭包自调用
 let closure: (Int, Int) -> Int = ({ () -> ((Int, Int) -> Int) in
     var inner = 0;
     return { (a: Int, b: Int) -> Int in
         inner += a
         return inner
     }
 })()
 print(closure(1, 2))
 print(closure(1, 2))
 print(closure(1, 2))
 
 // 嵌套函数
 func outerFunction() -> () -> Int {
     var runningTotal = 0
     func innerFunction() -> Int {
         runningTotal += 1
         return runningTotal
     }
     return innerFunction
 }
 let add = outerFunction()
 print(add())
 print(add())
 print(add())
 
 // 尾随闭包
 extension Int {
     func repetitions(task: (Int) -> Void) {
         for _ in 0..<self {
             task(222222)
         }
     }
 }
 // 原始
 3.repetitions(task: { (a: Int) in
     print(a)
 })
 // 尾随闭包:闭包移至小括号的外面
 3.repetitions(task: ) { (a: Int) in
     print(a)
 }
 // 标签可以取消
 3.repetitions() { (a: Int) in
     print(a)
 }
 // 小括号也可以取消
 3.repetitions { (a: Int) in
     print(a)
 }
 */

# pragma mark - OC

/**
- (NSInteger)stepForward:(NSInteger)a stepBackward:(NSInteger)b {
    return a + b;
}

 // Block不支持嵌套函数
- (NSInteger(^)(NSInteger a, NSInteger b))chooseStepFunction {
    return stepForward:stepBackward:;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger(^block)(NSInteger a, NSInteger b) = [self chooseStepFunction];
    block(1, 2);
}
 */

// block作为返回类型
// block作为形参类型
- (NSInteger(^)(NSInteger a, NSInteger b))funcParam1:(NSInteger(^)(NSInteger a, NSInteger b))block param2:(block_t)param2 {
    return block;
}

- (NSInteger(^)(NSInteger a, NSInteger b))funcParam1 {
    __block NSInteger inner = 0;
    return ^NSInteger(NSInteger a, NSInteger b) {
        return inner += a;
    };
    
    /**
    NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
        return inner += a;
    };
    return block;
     */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        // 传值
        NSInteger value = 100;
        NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
            NSLog(@"value = %ld", value);
            return a + b;
        };
        value = 200;
        block(1, 2); // 输出100
    }
    
    {
        // 传地址
        static NSInteger value = 100;
        static NSInteger value1 = 100;
        NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
            value1 = 200;
            NSLog(@"value = %ld, value1 = %ld", value, value1);
            return a + b;
        };
        value = 200;
        block(1, 2); // 输出200
    }
    
    {
        // 传地址
        __block NSInteger value = 100;
        __block NSInteger value1 = 100;
        NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
            value1 = 200;
            NSLog(@"value = %ld, value1 = %ld", value, value1);
            return a + b;
        };
        value = 200;
        block(1, 2); // 输出200
    }
    
    {
        // __weak修饰self表示block弱引用self
        // __strong修饰self表示__strong强引用self
        // __strong持有self,self持有block,不会造成循环引用
        // 如果不加__strong修饰,当block内部有延时操作时,若self被提前释放,此时执行self方法将失效
        // 如果加__strong修饰,当block内部有延时操作时,由于__strong强引用self,self不会被提前释放,此时执行self方法将有效
        __weak typeof(self) weakSelf = self;
        NSInteger(^block)(NSInteger a, NSInteger b) = ^NSInteger(NSInteger a, NSInteger b) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.name = @"name"; // 弱引用self
            _name = @"name"; // 强引用self
            return a + b;
        };
        block(1, 2); // 输出200
    }
    
    {
        __block NSInteger inner = 0;
        NSInteger(^block)(NSInteger a, NSInteger b) = [self funcParam1:^NSInteger(NSInteger a, NSInteger b) {
            inner = inner + 1;
            return inner;
        } param2:^NSInteger(NSInteger a, NSInteger b) {
            NSLog(@"当前block没有被回调");
            return a + b;
        }];
        NSLog(@"block = %ld", block(1, 2));
        NSLog(@"block = %ld", block(1, 2));
        NSLog(@"block = %ld", block(1, 2));
        
        //
        NSInteger(^block1)(NSInteger a, NSInteger b) = [self funcParam1];
        NSLog(@"block1 = %ld", block1(1, 2));
        NSLog(@"block1 = %ld", block1(1, 2));
        NSLog(@"block1 = %ld", block1(1, 2));
        
        //
        block_t(^block2)(void) = ^block_t(void) {
            __block NSInteger inner = 0;
            return ^NSInteger (NSInteger a, NSInteger b) {
                return inner += a;
            };
        };
        block_t block3 = block2();
        NSLog(@"block3 = %ld", block3(1, 2));
        NSLog(@"block3 = %ld", block3(1, 2));
        NSLog(@"block3 = %ld", block3(1, 2));
        
        // block自调用
        block_t block4 = (^block_t(void) {
            __block NSInteger inner = 0;
            return ^NSInteger (NSInteger a, NSInteger b) {
                return inner += a;
            };
        })();
        NSLog(@"block4 = %ld", block4(1, 2));
        NSLog(@"block4 = %ld", block4(1, 2));
        NSLog(@"block4 = %ld", block4(1, 2));
    }
}

@end
