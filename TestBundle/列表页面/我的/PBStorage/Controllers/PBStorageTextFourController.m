//
//  PBStorageTextFourController.m
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/19.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageTextFourController.h"
#import "PBDatabase.h"

@interface PBStorageTextFourController ()

@property (nonatomic, strong) NSString *filePath;

@end

@implementation PBStorageTextFourController

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
}

- (void)addBtn:(UIButton *)btn {
    // 文件路径
    NSString *filePath = [[PBSandBox path4Documents]stringByAppendingPathComponent:@"mytext"];
    self.filePath = filePath;
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSString *str = @"helloworldhelloworld";
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil]; // 在文件中以二进制形式存储
}

- (void)selectBtn:(UIButton *)btn {
    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"str = %@", str);
}

@end
