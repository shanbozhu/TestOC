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
#import "PBAllWelfareController.h"
#import "PBCalendarController.h"
#import "PBGesturePasswordController.h"
#import "PBSeatSelectionController.h"

@interface PBMineController ()<PBMineViewDelegate>

@end

@implementation PBMineController

- (BOOL)pb_navigationBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"我的";
    self.tabBarController.navigationController.navigationBar.barTintColor = [UIColor greenColor];
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
    UIViewController *vc;
    if (indexPath.row == 0) {
        vc = [[PBAllWelfareController alloc]init];
    } else if (indexPath.row == 1) {
        vc = [[PBCalendarController alloc]init];
    } else if (indexPath.row == 2) {
        vc = [[PBGesturePasswordController alloc]init];
    } else if (indexPath.row == 3) {
        vc = [[PBSeatSelectionController alloc]init];
    }
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}

@end
