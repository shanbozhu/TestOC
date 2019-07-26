//
//  PBMineController+Click.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/7/24.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBMineController+Click.h"
#import "PBMineView.h"
#import "PBAllWelfareController.h"
#import "PBCalendarController.h"
#import "PBGesturePasswordController.h"
#import "PBSeatSelectionController.h"
#import "PBQRCodeController.h"
#import "PBAnnotationController.h"
#import "PBImageTextController.h"
#import "PBYYTextController.h"
#import "PBAFNetworkingController.h"

@implementation PBMineController (Click)

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
    } else if (indexPath.row == 4) {
        vc = [[PBQRCodeController alloc]init];
    } else if (indexPath.row == 5) {
        vc = [[PBAnnotationController alloc]init];
    } else if (indexPath.row == 6) {
        vc = [[PBImageTextController alloc]init];
    } else if (indexPath.row == 7) {
        vc = [[PBYYTextController alloc]init];
    } else if (indexPath.row == 8) {
        vc = [[PBAFNetworkingController alloc]init];
    }
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}

@end
