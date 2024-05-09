//
//  PBCellHeightTwoController.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightTwoController.h"
#import "PBCellHeightTwoView.h"
#import "YYFPSLabel.h"
#import "PBCellHeightZero.h"

@interface PBCellHeightTwoController ()

@property (nonatomic, weak) PBCellHeightTwoView *testListTwoView;

@end

@implementation PBCellHeightTwoController

- (void)requestData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
    self.testListTwoView.testList = testList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    PBCellHeightTwoView *testListTwoView = [PBCellHeightTwoView testListTwoView];
    self.testListTwoView = testListTwoView;
    [self.view addSubview:testListTwoView];
    testListTwoView.frame = self.view.bounds;
    
    [self requestData];
}

@end
