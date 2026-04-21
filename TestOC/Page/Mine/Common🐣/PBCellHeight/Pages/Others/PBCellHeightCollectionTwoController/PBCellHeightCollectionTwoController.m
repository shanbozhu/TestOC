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
@property (nonatomic, weak) PBCycleCollectionView *oneTestListView;

@end

@implementation PBCellHeightCollectionTwoController

- (void)requestData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSString *jsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    // testList
    PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
    NSArray *tmpArr = [testList.data subarrayWithRange:NSMakeRange(0, 3)]; // 只取前3个
    testList.data = tmpArr;
    self.testListView.testList = testList;
    
    // oneTestList
    PBCellHeightZero *oneTestList = [PBCellHeightZero testListWithDict:jsonDict];
    NSArray *oneTmpArr = [oneTestList.data subarrayWithRange:NSMakeRange(0, 3)]; // 只取前3个
    oneTestList.data = oneTmpArr;
    self.oneTestListView.testList = oneTestList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    // PBCycleCollectionView
    PBCycleCollectionView *testListView = [[PBCycleCollectionView alloc] initWithFrame:CGRectMake(50, 200, self.view.bounds.size.width - 100, 200) scrollDirection:PBScrollDirectionHorizontal];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.autoPage = YES;
    
    // PBCycleCollectionView
    PBCycleCollectionView *oneTestListView = [[PBCycleCollectionView alloc] initWithFrame:CGRectMake(50, 500, self.view.bounds.size.width - 100, 200) scrollDirection:PBScrollDirectionVertical];
    self.oneTestListView = oneTestListView;
    [self.view addSubview:oneTestListView];
    oneTestListView.autoPage = YES;
    
    //
    [self requestData];
}

@end
