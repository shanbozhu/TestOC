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

@property (nonatomic, assign) NSInteger selectedIndex;

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

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    _viewControllers = viewControllers;
    self.tabBar.viewControllers = self.viewControllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *nav = self.viewControllers.firstObject;
    UIViewController *vc = nav.viewControllers.firstObject;
    [vc.view addSubview:self.tabBar];

    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    [nav didMoveToParentViewController:self];
    
    __weak typeof(self) weakSelf = self;
    self.tabBar.tabBarButtonClickBlock = ^(NSInteger index) {
        if (weakSelf.selectedIndex == index) {
            return;
        }
        
        [weakSelf.tabBar removeFromSuperview];
        UIViewController *selectedController = [weakSelf.viewControllers objectAtIndex:weakSelf.selectedIndex];
        if ([selectedController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *selectedNav = (UINavigationController *)selectedController;
            [selectedNav removeFromParentViewController];
            [selectedNav.view removeFromSuperview];
        }
        
        NSLog(@"index = %ld", index);
        UIViewController *controller = [weakSelf.viewControllers objectAtIndex:index];
        if ([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)controller;
            UIViewController *vc = nav.viewControllers.firstObject;
            [vc.view addSubview:weakSelf.tabBar];
            
            [weakSelf addChildViewController:nav];
            [weakSelf.view addSubview:nav.view];
            [nav didMoveToParentViewController:weakSelf];
            
            weakSelf.selectedIndex = index;
        }
    };
}

@end
