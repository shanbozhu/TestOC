//
//  PBMineController+Click.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/7/24.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBMineController+Click.h"
#import "PBMineView.h"
#import "PBWebViewController.h"
#import "PBCellHeightController.h"

@implementation PBMineController (Click)

- (NSArray *)pageArr {
    return @[@"PBSyntaxController",
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
