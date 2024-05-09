//
//  PBCellHeightCollectionZeroController.m
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightCollectionZeroController.h"
#import "PBCellHeightCollectionZeroView.h"
#import "YYFPSLabel.h"
#import "PBCellHeightZero.h"

@interface PBCellHeightCollectionZeroController ()

@property (nonatomic, weak) PBCellHeightCollectionZeroView *testListView;

@end

@implementation PBCellHeightCollectionZeroController

- (void)requestData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSString *jsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    // 3.把字典封装成模型
    PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
    
    // 4.把模型填充到视图
    self.testListView.testList = testList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    // 1.把视图加载到控制器
    PBCellHeightCollectionZeroView *testListView = [PBCellHeightCollectionZeroView testListView];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    
    // 2.把字典加载到控制器
    [self requestData];
}

@end
