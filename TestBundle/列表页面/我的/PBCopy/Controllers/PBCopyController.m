//
//  PBCopyController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBCopyController.h"
#import "PBCopy.h"

@interface PBCopyController ()

@property (nonatomic, copy) NSMutableArray *arr;

@end

@implementation PBCopyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 浅拷贝:只拷贝地址,不拷贝对象.指向同一个对象
    // 深拷贝:既拷贝地址,又拷贝对象.指向两个不同的对象,两个对象存储的值相同
    
    // 不可变类型的对象调用copy方法是浅拷贝,其他都是深拷贝
    // copy方法返回的对象是不可变的
    // mutableCopy方法返回的对象是可变的
    
    {
        // 不可变类型的对象调用copy方法是浅拷贝
        NSArray *arr = @[@"hello"];
        
        NSMutableArray *oneArr = [arr copy];
        //[oneArr addObject:@"world"]; // 会崩溃,copy方法返回的对象是不可变的
        NSLog(@"1-- oneArr = %p, oneArr = %@", oneArr, oneArr);
        NSLog(@"1-- arr = %p, arr = %@", arr, arr);
    }
    
    {
        // 不可变类型的对象调用mutableCopy方法是深拷贝
        NSArray *arr = @[@"hello"];
        
        NSMutableArray *oneArr = [arr mutableCopy];
        [oneArr addObject:@"world"]; // mutableCopy方法返回的对象是可变的
        NSLog(@"2-- oneArr = %p, oneArr = %@", oneArr, oneArr);
        NSLog(@"2-- arr = %p, arr = %@", arr, arr);
    }
    
    {
        // 可变类型的对象调用copy方法是深拷贝
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:@"hello"];
        
        NSMutableArray *oneArr = [arr copy];
        //[oneArr addObject:@"world"]; // 会崩溃,copy方法返回的对象是不可变的
        NSLog(@"3-- oneArr = %p, oneArr = %@", oneArr, oneArr);
        NSLog(@"3-- arr = %p, arr = %@", arr, arr);
    }
    
    {
        // 可变类型的对象调用mutableCopy方法是深拷贝
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:@"hello"];
        
        NSMutableArray *oneArr = [arr mutableCopy];
        [oneArr addObject:@"world"]; // mutableCopy方法返回的对象是可变的
        NSLog(@"4-- oneArr = %p, oneArr = %@", oneArr, oneArr);
        NSLog(@"4-- arr = %p, arr = %@", arr, arr);
    }
    
    {
        // @property (nonatomic, copy) NSMutableArray *arr;
        // 展开为如下
        // - (void)setArr:(NSMutableArray *)arr {
        //     _arr = [arr copy];
        // }
        
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:@"hello"];
        
        self.arr = arr;
        //[self.arr addObject:@"world"]; // 会崩溃,copy方法返回的对象是不可变的
        [arr addObject:@"world"];
        NSLog(@"5-- self.arr = %p, self.arr = %@", self.arr, self.arr);
        NSLog(@"5-- arr = %p, arr = %@", arr, arr);
    }
    
    {
        PBCopy *testList = [[PBCopy alloc]init];
        testList.name = @"hello";
        
        PBCopy *oneTestList = [testList copy];
        oneTestList.name = @"world";
        NSLog(@"6-- oneTestList = %p, oneTestList.name = %p, oneTestList.name = %@", oneTestList, oneTestList.name, oneTestList.name);
        NSLog(@"6-- testList = %p, testList.name = %p, testList.name = %@", testList, testList.name, testList.name);
    }
}

@end
