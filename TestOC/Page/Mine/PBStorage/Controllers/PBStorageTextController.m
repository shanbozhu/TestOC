//
//  PBStorageTextController.m
//  TestOC
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
    
    // 指定路径创建文件
    self.filePath = [PBSandBox absolutePathWithRelativePath:@"/Documents/PBStorage/testAr.ar"];
    [PBSandBox createFileAtPath:self.filePath];
    
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
    // 数据
    PBStorageText *testText = [[PBStorageText alloc]init];
    testText.name = HELLOWORLD;
    testText.age = 1000;
    
    NSString *str = HELLOWORLD;
    NSArray *arr = @[testText, testText];
    NSDictionary *dic = @{@"testText":testText, @"name":HELLOWORLD, @"testTextArr":@[testText, testText]};
    
    // block是自定义类型数据,不支持归档,会崩溃
    void(^block)(void) = ^void(void){
        
    };
    
    // 归档
    NSData *data = [PBArchiver dataWithObjects:@[str, arr, dic] keys:@[@"str", @"arr", @"dic"]];
    
    // 归档数据存储到本地文件
    [data writeToFile:self.filePath atomically:YES];
}

- (void)unArchiverBtn:(UIButton *)btn {
    // 从本地文件读取归档数据
    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
    
    // 解档
    NSArray *objs = [PBArchiver objectsWithData:data keys:@[@"str", @"arr", @"dic"]];
    
    // 数据
    NSString *str = objs[0];
    NSArray *arr = objs[1];
    NSDictionary *dic = objs[2];
    
    PBStorageText *testText = arr[0];
    PBStorageText *testText1 = dic[@"testText"];
    
    NSLog(@"str = %@, testText.name = %@, testText.age = %ld, testText1.name = %@, testText1.age = %ld", str, testText.name, testText.age, testText1.name, testText1.age);
}

@end
