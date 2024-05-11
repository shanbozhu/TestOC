//
//  PBStorageDataBaseOneController.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/15.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageDataBaseOneController.h"
#import "PBDatabase.h"
#import <YYModel/YYModel.h>
#import "PBStorageList.h"

@interface PBStorageDataBaseOneController ()


@end

@implementation PBStorageDataBaseOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addBtn];
    addBtn.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 40);
    [addBtn setTitle:@"添加数据(增,改)" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtn:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:selectBtn];
    selectBtn.frame = CGRectMake(20, 160, [UIScreen mainScreen].bounds.size.width-40, 40);
    [selectBtn setTitle:@"查找数据(查)" forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    selectBtn.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:deleteBtn];
    deleteBtn.frame = CGRectMake(20, 220, [UIScreen mainScreen].bounds.size.width-40, 40);
    [deleteBtn setTitle:@"删除一条数据(删)" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *deleteAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:deleteAllBtn];
    deleteAllBtn.frame = CGRectMake(20, 280, [UIScreen mainScreen].bounds.size.width-40, 40);
    [deleteAllBtn setTitle:@"删除所有数据(删)" forState:UIControlStateNormal];
    [deleteAllBtn addTarget:self action:@selector(deleteAllBtn:) forControlEvents:UIControlEventTouchUpInside];
    deleteAllBtn.backgroundColor = [UIColor lightGrayColor];
}

- (void)addBtn:(UIButton *)btn {
    PBDatabase *db = [PBDatabase sharedDatabase];
    
    // NSString
    NSString *str = HELLOWORLD;
    [db setValue:str forKey:@"str"];
    
    // NSDictionary
    NSDictionary *dic = @{@"name":HELLOWORLD, @"age":@(4)};
    [db setValue:dic forKey:@"dic"];
    
    // NSArray
    NSArray *arr = @[@"hello", @"world"];
    [db setValue:arr forKey:@"arr"];
    
    // NSNumber
    NSNumber *num = @(100);
    [db setValue:num forKey:@"age"];
    
    // PBStorageList
    PBStorageList *testList = [[PBStorageList alloc]init];
    testList.name = HELLOWORLD;
    testList.age = 100;
    
    [db setValue:testList forKey:@"testList"];
}

- (void)selectBtn:(UIButton *)btn {
    PBDatabase *db = [PBDatabase sharedDatabase];
    
    // NSString
    NSString *strTmp = [db valueForKey:@"str"];
    NSLog(@"strTmp = %@", strTmp);
    
    // NSDictionary
    NSDictionary *dicTmp = [db valueForKey:@"dic"];
    NSLog(@"dicTmp[@\"name\"] = %@, dicTmp[@\"age\"] = %@", dicTmp[@"name"], dicTmp[@"age"]);
    
    // NSArray
    NSArray *arrTmp = [db valueForKey:@"arr"];
    NSLog(@"arrTmp[0] = %@, arrTmp[1] = %@", arrTmp[0], arrTmp[1]);
    
    // NSNumber
    NSNumber *numTmp = [db valueForKey:@"age"];
    NSLog(@"numTmp = %@", numTmp);
    
    // PBStorageList
    PBStorageList *testListTmp = [db valueForKey:@"testList"];
    NSLog(@"testListTmp.name = %@, testListTmp.age = %ld", testListTmp.name, testListTmp.age);
}

- (void)deleteBtn:(UIButton *)btn {
    PBDatabase *db = [PBDatabase sharedDatabase];
    [db removeObjectForKey:@"testList"];
}

- (void)deleteAllBtn:(UIButton *)btn {
    PBDatabase *db = [PBDatabase sharedDatabase];
    [db removeAllObjects];
}

@end
