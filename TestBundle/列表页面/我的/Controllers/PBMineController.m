//
//  PBMineController.m
//  PBMine
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBMineController.h"
#import <YYText/YYText.h>
#import "PBMineView.h"

@interface PBMineController ()<PBMineViewDelegate>

@end

@implementation PBMineController

- (BOOL)pb_navigationBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"self.view.frame.size.height = %lf", self.view.frame.size.height);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // mineView
    PBMineView *mineView = [PBMineView mineView];
    [self.view addSubview:mineView];
    mineView.frame = self.view.bounds;
    mineView.delegate = self;
}

// delegate
- (void)mineView:(PBMineView *)mineView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath.row = %ld", indexPath.row);
}

@end
