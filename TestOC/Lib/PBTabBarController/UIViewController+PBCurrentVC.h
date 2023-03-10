//
//  UIViewController+PBCurrentVC.h
//  TestOC
//
//  Created by matrix on 2023/3/10.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (PBCurrentVC)

// 当前展示的VC
- (UIViewController *)bba_currentTopViewController;

@end

NS_ASSUME_NONNULL_END
