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
    if (indexPath.row == 0) {
        PBAllWelfareController *allWelfareController = [[PBAllWelfareController alloc]init];
        allWelfareController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:allWelfareController animated:YES];
        allWelfareController.view.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row == 1) {
        PBCalendarController *calendarController = [[PBCalendarController alloc]init];
        calendarController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:calendarController animated:YES];
        calendarController.view.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row == 2) {
        PBGesturePasswordController *gesturePasswordController = [[PBGesturePasswordController alloc]init];
        gesturePasswordController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:gesturePasswordController animated:YES];
        gesturePasswordController.view.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row == 3) {
        PBSeatSelectionController *seatSelectionController = [[PBSeatSelectionController alloc]init];
        seatSelectionController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:seatSelectionController animated:YES];
        seatSelectionController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
