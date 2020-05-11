//
//  PBCellHeightOneController.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightOneController.h"
#import "PBCellHeightOneView.h"
#import "YYFPSLabel.h"
#import "PBCellHeightZero.h"

@interface PBCellHeightOneController ()

@property (nonatomic, weak) PBCellHeightOneView *testListOneView;

@end

@implementation PBCellHeightOneController

- (void)requestData {
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"PBCellHeightZero" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"jsonStr = %@, jsonDict = %@", jsonStr, jsonDict);
    
    PBCellHeightZero *testList = [PBCellHeightZero testListWithDict:jsonDict];
    self.testListOneView.testList = testList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    PBCellHeightOneView *testListOneView = [PBCellHeightOneView testListOneView];
    self.testListOneView = testListOneView;
    [self.view addSubview:testListOneView];
    testListOneView.frame = self.view.bounds;
    
    [self requestData];
}

@end
