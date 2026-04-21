//
//  PBCellHeightFourController.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFourController.h"
#import "PBCellHeightFourView.h"
#import "YYFPSLabel.h"
#import "PBCellHeightZero.h"

@interface PBCellHeightFourController ()

@property (nonatomic, weak) PBCellHeightFourView *testListFourView;

@end

@implementation PBCellHeightFourController

- (void)requestData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSString *jsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
    self.testListFourView.testList = testList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    PBCellHeightFourView *testListFourView = [PBCellHeightFourView testListFourView];
    self.testListFourView = testListFourView;
    [self.view addSubview:testListFourView];
    testListFourView.frame = self.view.bounds;
    
    [self requestData];
}

@end
