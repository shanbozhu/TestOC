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
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
    self.testListView.testList = testList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];

    PBCellHeightZeroView *testListView = [PBCellHeightZeroView testListView];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    
    [self requestData];
}

@end
