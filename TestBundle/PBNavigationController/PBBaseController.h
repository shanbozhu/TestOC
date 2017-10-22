//
//  PBBaseController.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/10/7.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBNavigationController.h"


@interface UIViewController (PBNavigationBar)

-(BOOL)pb_navigationBarHidden; //重写此方法返回NO,隐藏导航栏
-(BOOL)pb_panGestureRecognizerEnabled; //重写此方法返回NO,屏蔽全屏侧滑,降级为边缘侧滑
-(BOOL)pb_popGestureRecognizerEnabled; //重写此方法返回NO,屏蔽边缘侧滑,降级为不侧滑

@end


@interface PBBaseController : UIViewController

@end
