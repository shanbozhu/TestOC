//
//  PBLinkageTopController.m
//  TestOC
//
//  Created by shanbo on 2022/1/19.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageTopController.h"
#import "PBLinkageTopOneListController.h"
#import "PBLinkageTopTwoListController.h"
#import <SDCycleScrollView/SDCycleScrollView.h>

@interface PBLinkageTopController () <YNPageViewControllerDataSource, YNPageViewControllerDelegate>

@property (nonatomic, copy) NSArray *imagesURLs;

@end

@implementation PBLinkageTopController

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
}

+ (instancetype)linkageTopController {
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle = YNPageStyleSuspensionTop;
    configration.showTabbar = NO;
    configration.showNavigation = YES;
    configration.scrollMenu = NO;
    configration.aligmentModeCenter = NO;
    
    PBLinkageTopController *vc = [PBLinkageTopController pageViewControllerWithControllers:[self getArrayVCs]
                                                                                    titles:[self getArrayTitles]
                                                                                    config:configration];
    vc.dataSource = vc;
    vc.delegate = vc;
    
    // 轮播图
    SDCycleScrollView *autoScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, APPLICATION_FRAME_WIDTH, 210) imageURLStringsGroup:vc.imagesURLs];
    autoScrollView.autoScroll = NO;
    vc.headerView = autoScrollView;
    return vc;
}

+ (NSArray *)getArrayVCs {
    PBLinkageTopOneListController *firstVC = [[PBLinkageTopOneListController alloc] init];
    PBLinkageTopTwoListController *secondVC = [[PBLinkageTopTwoListController alloc] init];
    return @[firstVC, secondVC];
}


#pragma mark -
- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController pageForIndex:(NSInteger)index {
    UIViewController *vc = pageViewController.controllersM[index];
    if (index == 0) {
        return [(PBLinkageTopOneListController *)vc tableView];
    } else {
        return [(PBLinkageTopTwoListController *)vc tableView];
    }
}

#pragma mark -
+ (NSArray *)getArrayTitles {
    return @[@"鞋子", @"衣服"];
}

- (NSArray *)imagesURLs {
    if (!_imagesURLs) {
        _imagesURLs = @[
            @"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
            @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
            @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"];
    }
    return _imagesURLs;
}

@end
