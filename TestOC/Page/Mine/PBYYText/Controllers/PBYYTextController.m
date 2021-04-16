//
//  PBYYTextController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/9/22.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBYYTextController.h"
#import "PBYYTextView.h"
#import "PBYYText.h"

@interface PBYYTextController ()

@end

@implementation PBYYTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PBYYTextView *testListView = [PBYYTextView testListView];
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            testListView.testList = [[PBYYText alloc]init];
        });
    });
}

@end
