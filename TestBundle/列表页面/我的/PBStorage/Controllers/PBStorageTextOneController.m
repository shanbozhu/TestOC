//
//  PBStorageTextOneController.m
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/18.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageTextOneController.h"
#import "PBStorageText.h"
#import "PBDatabase.h"

@interface PBStorageTextOneController ()

@end

@implementation PBStorageTextOneController

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
}

- (void)addBtn:(UIButton *)btn {
    // PBStorageText
    PBStorageText *testText = [[PBStorageText alloc]init];
    testText.name = @"helloworld";
    testText.age = 1000;
    
    NSData *data = [PBArchiver dataWithObject:testText key:@"testText"];
    [[NSUserDefaults standardUserDefaults]setValue:data forKey:@"testText"];
}

- (void)selectBtn:(UIButton *)btn {
    NSData *data = [[NSUserDefaults standardUserDefaults]valueForKey:@"testText"];
    PBStorageText *testText = [PBArchiver objectWithData:data key:@"testText"];
    NSLog(@"testText.name = %@, testText.age = %ld", testText.name, testText.age);
}

- (void)deleteBtn:(UIButton *)btn {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"testText"];
}

@end
