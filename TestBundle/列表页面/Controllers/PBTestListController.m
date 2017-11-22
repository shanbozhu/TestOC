//
//  PBTestListController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestListController.h"
#import "PBTestListView.h"
#import "YYFPSLabel.h"


@interface PBTestListController ()

@property(nonatomic, weak)PBTestListView *testListView;

@end

@implementation PBTestListController



- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];


    PBTestListView *testListView = [PBTestListView testListView];
    self.testListView = testListView;
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    
    
    
}





@end
