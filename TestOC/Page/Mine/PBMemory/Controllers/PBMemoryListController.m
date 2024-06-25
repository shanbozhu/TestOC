//
//  PBMemoryListController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBMemoryListController.h"
#import "PBMemoryList.h"

@interface PBMemoryListController ()

@end

@implementation PBMemoryListController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1.Build Settings -> Automatic Reference Counting 设为YES
    // 2.指向该对象的强引用数为0,对象被释放.即retainCount = 0时,对象被释放
    
    PBMemoryList *testList = [[PBMemoryList alloc]init];
    
    PBMemoryList *testList1 = testList; // 执行此语句会自动将对象的强引用数加1,相当于MRC下执行 PBMemoryList *testList1 = [testList retain];
    
    testList = nil; // 执行此语句会自动将对象的强引用数减1,相当于MRC下执行 PBMemoryList *testList1 = [testList release];
    testList1 = nil;
    
    NSLog(@"先执行[PBMemoryList对象被释放了],在执行此语句");
}

- (void)dealloc {
    NSLog(@"PBMemoryListController对象被释放了");
}

@end
