//
//  PBYYTextController.m
//  TestBundle
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

- (BOOL)pb_panGestureRecognizerEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PBYYTextView *testListView = [PBYYTextView testListView];
    [self.view addSubview:testListView];
    testListView.frame = self.view.bounds;
    
    testListView.testList = [[PBYYText alloc]init];
}

@end
