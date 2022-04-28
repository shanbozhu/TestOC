//
//  PBCellHeightCollectionTwoController.m
//  TestOC
//
//  Created by shanbo on 2022/4/23.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightCollectionTwoController.h"
#import "PBCycleCollectionView.h"
#import "YYFPSLabel.h"
#import "PBCellHeightZero.h"

@interface PBCellHeightCollectionTwoController ()

@property (nonatomic, weak) PBCycleCollectionView *testListView;

@end

@implementation PBCellHeightCollectionTwoController

- (void)requestData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    // testList
    PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
    NSArray *tmpArr = [testList.data subarrayWithRange:NSMakeRange(0, 3)]; // 只取前3个
    testList.data = tmpArr;
    self.testListView.testList = testList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    // PBCycleCollectionView
    PBCycleCollectionView *testListView = [[PBCycleCollectionView alloc] initWithFrame:CGRectMake(50, 200, self.view.bounds.size.width - 100, 200)];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.autoPage = YES;
    
    //
    [self requestData];
}

@end
