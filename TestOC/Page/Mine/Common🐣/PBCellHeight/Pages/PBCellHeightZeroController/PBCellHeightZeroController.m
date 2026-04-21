//
//  PBCellHeightZeroController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightZeroController.h"
#import "PBCellHeightZeroView.h"
#import "YYFPSLabel.h"
#import "PBCellHeightZero.h"

@interface PBCellHeightZeroController ()

@property (nonatomic, weak) PBCellHeightZeroView *testListView;

@end

@implementation PBCellHeightZeroController

- (void)requestData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSString *jsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    {
        NSDictionary *jsonDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        // jsonDict = (null)
        NSLog(@"jsonDict = %@", jsonDict);
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 3. 把字典封装成模型
        PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            // 4. 把模型填充到视图
            strongSelf.testListView.testList = testList;
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    // 1. 把视图加载到控制器
    PBCellHeightZeroView *testListView = [PBCellHeightZeroView testListView];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    
    // 2. 把字典加载到控制器
    [self requestData];
}

@end
