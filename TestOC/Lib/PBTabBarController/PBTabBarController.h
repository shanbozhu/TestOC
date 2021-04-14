//
//  PBTabBarController.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/8.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBTabBar.h"
#import "PBTabBarButtonItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (PBTabBarButton)

@property (nonatomic, strong, setter=pb_setTabBarButtonItem:) PBTabBarButtonItem *pb_tabBarButtonItem;

@end

@interface PBTabBarController : UIViewController

@property(nullable, nonatomic,copy) NSArray<__kindof UIViewController *> *viewControllers;


@end

NS_ASSUME_NONNULL_END
