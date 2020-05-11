//
//  PBStorageTextTwoController.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/17.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageTextTwoController.h"
#import "PBSandBox.h"
#import "PBStorageText.h"
#import "PBDataPList.h"

@interface PBStorageTextTwoController ()

@property (nonatomic, copy) NSString *filePath;

@end

@implementation PBStorageTextTwoController

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
    // NSString
    [[PBDataPList sharedDataPList]setValue:@"helloworld" forKey:@"name"];
    
    // PBStorageText
    PBStorageText *testText = [[PBStorageText alloc]init];
    testText.name = @"helloworld";
    testText.age = 1000;

    [[PBDataPList sharedDataPList]setValue:testText forKey:@"testText"];
}

- (void)selectBtn:(UIButton *)btn {
    // NSString
    NSString *name = [[PBDataPList sharedDataPList]valueForKey:@"name"];
    NSLog(@"name = %@", name);
    
    // PBStorageText
    PBStorageText *testText  = [[PBDataPList sharedDataPList]valueForKey:@"testText"];
    NSLog(@"testText.name = %@, testText.age = %ld", testText.name, testText.age);
}

- (void)deleteBtn:(UIButton *)btn {
    [[PBDataPList sharedDataPList]removeObjectForKey:@"testText"];
}

- (void)deleteAllBtn:(UIButton *)btn {
    [[PBDataPList sharedDataPList]removeAllObjects];
}

@end
