//
//  PBMemoryListMRCController.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/29.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#ifdef OPENMRC
#import "PBMemoryListMRCController.h"
#import "PBMemoryListMRC.h"

@interface PBMemoryListMRCController ()

@end

@implementation PBMemoryListMRCController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1.Build Settings -> Automatic Reference Counting 设为NO
    // 2.下面对象调用retain和release方法时要成对存在,这样写一般都能正常释放内存,几乎不用仔细考虑每一步内存释放情况
    
    PBMemoryListMRC *testListMRC = [[PBMemoryListMRC alloc]init];
    
    PBMemoryListMRC *testListMRC1 = [testListMRC retain]; // retain方法将对象的强引用数加1,返回对象地址.相当于让testListMRC1变为强引用
    
    PBMemoryListMRCOne *testListMRCOne = [[PBMemoryListMRCOne alloc]init];
    testListMRC1.testListMRCOne = testListMRCOne;
    
    [testListMRCOne release];
    
    [testListMRC1 release];
    [testListMRC release]; // release方法将对象的强引用数减1
    
    NSLog(@"先执行[PBMemoryListMRC对象被释放了],在执行此语句");
}

- (void)dealloc {
    [super dealloc];
    NSLog(@"PBMemoryListMRCController对象被释放了");
}

@end
#endif
