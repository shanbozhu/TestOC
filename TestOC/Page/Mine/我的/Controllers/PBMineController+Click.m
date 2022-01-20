//
//  PBMineController+Click.m
//  TestOC
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
#import "PBWebViewController.h"
#import "PBCellHeightController.h"
#import "PBTimerController.h"
#import "PBCopyController.h"
#import "PBKVOController.h"
#import "PBMemoryController.h"
#import "PBStorageController.h"
#import "PBGCDController.h"
#import "PBAlgorithmController.h"
#import "PBAVPlayerListController.h"
#import "PBUniversalLinkController.h"
#import "PBRuntimeController.h"
#import "PBContentController.h"
#import "PBLinkageController.h"

@implementation PBMineController (Click)

- (NSArray *)pageArr {
    return @[@"PBLinkageController",
             @"PBAllLinkageController",
             @"PBSyntaxController",
             @"PBContentController",
             @"PBAllWelfareController",
             @"PBCalendarController",
             @"PBGesturePasswordController",
             @"PBSeatSelectionController",
             @"PBQRCodeController",
             @"PBAnnotationController",
             @"PBImageTextController",
             @"PBYYTextController",
             @"PBAFNetworkingController",
             @"PBWebViewController",
             @"PBCellHeightController",
             @"PBTimerController",
             @"PBCopyController",
             @"PBKVOController",
             @"PBMemoryController",
             @"PBStorageController",
             @"PBGCDController",
             @"PBAlgorithmController",
             @"PBAVPlayerListController",
             @"PBUniversalLinkController",
             @"PBRuntimeController",
             @"PBAnimationController",
             @"PBSwiftController"];
}

// delegate
- (void)mineView:(PBMineView *)mineView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *page = self.pageArr[indexPath.row];
    Class class = NSClassFromString(page);
    UIViewController *vc = [[class alloc] init];
    if ([page isEqualToString:@"PBSwiftController"] && !vc) {
        vc = [[PBSwiftController alloc] init];
    }
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}

@end
