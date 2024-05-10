//
//  PBCommonController.m
//  PBCommon
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBCommonController.h"
#import "PBCommonView.h"
#import "PBLinkageController.h"

@interface PBCommonController ()<PBCommonViewDelegate>

@end

@implementation PBCommonController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    PBCommonView *commonView = [PBCommonView commonView];
    [self.view addSubview:commonView];
    commonView.frame = self.view.bounds;
    commonView.delegate = self;
}

- (void)commonView:(PBCommonView *)commonView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [[PBLinkageController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
}

@end
