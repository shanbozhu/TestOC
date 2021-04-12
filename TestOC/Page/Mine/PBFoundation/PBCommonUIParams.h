//
//  PBCommonUIParams.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/8.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// iOS11+,状态栏高度等于顶部安全区域高度; iOS11以下,状态栏高度为20,顶部安全区域高度为0
#define APPLICATION_STATUSBAR_HEIGHT ([PBCommonUIParams statusBarHeight])

/// 导航栏内容高度
#define APPLICATION_NAVIGATIONBAR_CONTENT_HEIGHT (44)
/// 导航栏高度
#define APPLICATION_NAVIGATIONBAR_HEIGHT ([PBCommonUIParams navigationBarHeight])

/// 标签栏内容高度
#define APPLICATION_TABBAR_CONTENT_HEIGHT (49)
/// 标签栏高度
#define APPLICATION_TABBAR_HEIGHT ([PBCommonUIParams tabBarHeight])

/// 屏幕宽度
#define APPLICATION_FRAME_WIDTH ([PBCommonUIParams applicationFrameWidth])
/// 屏幕高度
#define APPLICATION_FRAME_HEIGHT ([PBCommonUIParams applicationFrameHeight])

#define APPLICATION_SAFE_AREA_TOP_MARGIN ([PBCommonUIParams safeTopMargin])
#define APPLICATION_SAFE_AREA_BOTTOM_MARGIN ([PBCommonUIParams safeBottomMargin])
#define APPLICATION_SAFE_AREA_LEFT_MARGIN ([PBCommonUIParams safeLeftMargin])
#define APPLICATION_SAFE_AREA_RIGHT_MARGIN ([PBCommonUIParams safeRightMargin])

@interface PBCommonUIParams : NSObject

+ (CGFloat)statusBarHeight;
+ (CGFloat)navigationBarHeight;
+ (CGFloat)tabBarHeight;

+ (CGFloat)applicationFrameWidth;
+ (CGFloat)applicationFrameHeight;

+ (CGFloat)safeTopMargin;
+ (CGFloat)safeBottomMargin;
+ (CGFloat)safeLeftMargin;
+ (CGFloat)safeRightMargin;

+ (BOOL)isFringeScreen;

@end

NS_ASSUME_NONNULL_END
