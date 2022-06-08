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

@interface PBCellHeightFiveController ()

@property (nonatomic, weak) PBCellHeightFiveView *testListFiveView;

@end

@implementation PBCellHeightFiveController

- (void)requestData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
    self.testListFiveView.testList = testList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    PBCellHeightFiveView *testListFiveView = [PBCellHeightFiveView testListFiveView];
    self.testListFiveView = testListFiveView;
    [self.view addSubview:testListFiveView];
    testListFiveView.frame = self.view.bounds;
    
    [self requestData];
}

@end
