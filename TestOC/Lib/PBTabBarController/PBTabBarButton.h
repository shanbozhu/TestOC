//
//  PBTabBarButton.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/9.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBTabBarButtonItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBTabBarButton : UIButton

@property (nonatomic, strong) PBTabBarButtonItem *buttonItem;

@end

NS_ASSUME_NONNULL_END
