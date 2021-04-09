//
//  PBStorageTextFourController.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/19.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageTextFourController.h"
#import "PBDatabase.h"

@interface PBStorageTextFourController ()

@property (nonatomic, copy) NSString *filePath;

@end

@implementation PBStorageTextFourController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 指定路径创建文件
    self.filePath = [PBSandBox absolutePathWithRelativePath:@"/Documents/PBStorage/testText.txt"];
    [PBSandBox createFileAtPath:self.filePath];
    
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
    NSString *str = @"helloworldhelloworld";
    [str writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)selectBtn:(UIButton *)btn {
    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"str = %@", str);
}

@end
