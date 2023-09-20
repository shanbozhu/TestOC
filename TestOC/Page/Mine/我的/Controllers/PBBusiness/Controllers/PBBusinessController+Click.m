//
//  PBBusinessController+Click.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/7/24.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBBusinessController+Click.h"
#import "PBBusinessView.h"

@implementation PBBusinessController (Click)

- (NSArray *)pageArr {
    return @[@"PBImageTextController",
             @"PBCalendarController",
             @"PBSeatSelectionController",
             @"PBAnnotationController",
             @"PBQRCodeController",
             @"PBPanGestureRecognizer"];
}

// delegate
- (void)businessView:(PBBusinessView *)businessView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *page = self.pageArr[indexPath.row];
    Class aClass = NSClassFromString(page);
    if (!aClass) {
        aClass = NSClassFromString([NSString stringWithFormat:@"TestOC.%@", page]);
    }
    UIViewController *vc = [[aClass alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.title = page;
    
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}

@end
