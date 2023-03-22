//
//  PBMineController+Click.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/7/24.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBMineController+Click.h"
#import "PBMineView.h"

@implementation PBMineController (Click)

- (NSArray *)pageArr {
    return @[@"PBCommonController",
             @"PBBusinessController",
             @"PBSwiftController",
             @"PBMasonryController",
             @"PBArrayController",
             @"PBProtocolController",
             @"PBSyntaxController",
             @"PBAFNetworkingController",
             @"PBWebViewController",
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
             @"PBAnimationController"];
}

// delegate
- (void)mineView:(PBMineView *)mineView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *page = self.pageArr[indexPath.row];
    Class class = NSClassFromString(page);
    if (!class) {
        class = NSClassFromString([NSString stringWithFormat:@"TestOC.%@", page]); // oc调用swift
    }
    UIViewController *vc = [[class alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.title = page;
    
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}

@end
