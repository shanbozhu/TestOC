//
//  PBCommonController+Click.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/7/24.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBCommonController+Click.h"
#import "PBCommonView.h"
#import "PBAllChannelController.h"
#import "PBYYTextController.h"
#import "PBCellHeightController.h"
#import "PBContentController.h"
#import "PBLinkageController.h"

@implementation PBCommonController (Click)

- (NSArray *)pageArr {
    return @[@"PBYYTextController",
             @"PBContentController",
             @"PBCellHeightController",
             @"PBLinkageController",
             @"PBAllChannelController"];
}

// delegate
- (void)CommonView:(PBCommonView *)CommonView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *page = self.pageArr[indexPath.row];
    Class class = NSClassFromString(page);
    if (!class) {
        class = NSClassFromString([NSString stringWithFormat:@"TestOC.%@", page]);
    }
    UIViewController *vc = [[class alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.title = page;
    
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}

@end
