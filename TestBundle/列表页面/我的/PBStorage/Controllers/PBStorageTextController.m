//
//  PBStorageTextController.m
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/17.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageTextController.h"
#import "PBStorageText.h"
#import "PBSandBox.h"
#import "PBDatabase.h"

@interface PBStorageTextController ()

@property (nonatomic, copy) NSString *filePath;

@end

@implementation PBStorageTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *archiverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:archiverBtn];
    archiverBtn.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 40);
    [archiverBtn setTitle:@"归档" forState:UIControlStateNormal];
    [archiverBtn addTarget:self action:@selector(archiverBtn:) forControlEvents:UIControlEventTouchUpInside];
    archiverBtn.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *unArchiverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:unArchiverBtn];
    unArchiverBtn.frame = CGRectMake(20, 160, [UIScreen mainScreen].bounds.size.width-40, 40);
    [unArchiverBtn setTitle:@"解档" forState:UIControlStateNormal];
    [unArchiverBtn addTarget:self action:@selector(unArchiverBtn:) forControlEvents:UIControlEventTouchUpInside];
    unArchiverBtn.backgroundColor = [UIColor lightGrayColor];
}

- (void)archiverBtn:(UIButton *)btn {
    PBStorageText *testText = [[PBStorageText alloc]init];
    testText.name = @"helloworld";
    testText.age = 1000;
    
    NSString *str = @"helloworld";
    NSArray *arr = @[testText, testText];
    NSDictionary *dic = @{@"testText":testText, @"name":@"helloworld", @"testTextArr":@[testText, testText]};
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    
    [archiver encodeObject:str forKey:@"str"];
    [archiver encodeObject:arr forKey:@"arr"];
    [archiver encodeObject:dic forKey:@"dic"];
    
    [archiver finishEncoding];
    
    // 文件路径
    NSString *filePath = [[PBSandBox path4Documents]stringByAppendingPathComponent:@"myar.ar"];
    self.filePath = filePath;
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    // 归档数据存储到本地文件
    [data writeToFile:filePath atomically:YES];
}

- (void)unArchiverBtn:(UIButton *)btn {
    // 从本地文件读取归档数据
    NSMutableData *data = [NSMutableData dataWithContentsOfFile:self.filePath];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    
    NSString *str = [unarchiver decodeObjectForKey:@"str"];
    NSArray *arr = [unarchiver decodeObjectForKey:@"arr"];
    NSDictionary *dic = [unarchiver decodeObjectForKey:@"dic"];
    
    [unarchiver finishDecoding];
    
    PBStorageText *testText = arr[0];
    PBStorageText *testText1 = dic[@"testText"];
    
    NSLog(@"str = %@, testText.name = %@, testText.age = %ld, testText1.name = %@, testText1.age = %ld", str, testText.name, testText.age, testText1.name, testText1.age);
}

@end
