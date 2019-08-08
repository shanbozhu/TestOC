//
//  UIImageView+PBPhBrowserView.h
//  TestBundle
//
//  Created by DaMaiIOS on 16/7/26.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIImageView (PBPhBrowserView)

// 利用runtime运行机制在分类中动态添加属性
@property (nonatomic, assign) NSInteger pbTag;

@end
