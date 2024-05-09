//
//  PBCellHeightFiveController.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFiveController.h"
#import "PBCellHeightFiveView.h"
#import "YYFPSLabel.h"
#import "PBCellHeightZero.h"
#import "PBCellHeightFiveCellVM.h"

@interface PBCellHeightFiveController () <PBCellHeightFiveViewDelegate>

@property (nonatomic, weak) PBCellHeightFiveView *testListView;

@end

@implementation PBCellHeightFiveController

- (void)requestDataWithSinceId:(NSInteger)sinceId status:(NSInteger)status {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    // testList
    PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
    
    // 提供个假值,模拟"暂无更多内容"
    if (status != 0 && arc4random_uniform(3) == 0) {
        testList.data = nil;
    }
    
    if (status == 0) {
        self.testListView.testList = testList;
    } else {
        NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.testListView.testList.data];
        [tmpArr addObjectsFromArray:testList.data];
        
        if (testList.data.count == 0) {
            self.testListView.testList.dataAddIsNull = YES;
        } else {
            self.testListView.testList.dataAddIsNull = NO;
        }
        self.testListView.testList.data = tmpArr;
        self.testListView.testList = self.testListView.testList;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    PBCellHeightFiveView *testListView = [PBCellHeightFiveView testListFiveView];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    testListView.delegate = self;
    
    // 默认刷新头
    [self requestDataWithSinceId:0 status:0];
}

- (void)cellHeightFiveView:(PBCellHeightFiveView *)cellHeightFiveView sinceId:(NSInteger)sinceId status:(NSInteger)status {
    [self requestDataWithSinceId:sinceId status:status];
}

@end
