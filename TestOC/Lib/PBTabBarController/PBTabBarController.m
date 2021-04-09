//
//  PBTabBarController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/8.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBTabBarController.h"

@interface PBTabBarController ()

@property (nonatomic, strong) PBTabBar *tabBar;

@end

@implementation PBTabBarController

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        PBTabBar *tabBar = [[PBTabBar alloc] init];
        self.tabBar = tabBar;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    UINavigationController *nav = self.viewControllers.firstObject;
    UIViewController *vc = nav.viewControllers.firstObject;
    [vc.view addSubview:self.tabBar];
//    [self.view addSubview:self.tabBar];
    

    //
    [self.view addSubview:nav.view];
}



@end
