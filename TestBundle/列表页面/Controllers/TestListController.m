//
//  TestListController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "TestListController.h"
#import "TestListView.h"
#import "YYFPSLabel.h"


@interface TestListController ()

@property(nonatomic, weak)TestListView *testListView;

@end

@implementation TestListController



- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];


    TestListView *testListView = [TestListView testListView];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    
    
    
}





@end
