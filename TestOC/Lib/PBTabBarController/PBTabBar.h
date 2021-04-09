//
//  PBTabBar.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/8.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBTabBarButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBTabBar : UIView

@property(nullable, nonatomic,copy) NSArray<__kindof UIViewController *> *viewControllers;

@property (nonatomic, copy) void(^tabBarButtonClickBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
