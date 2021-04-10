//
//  UIView+CommonExtension.h
//  BBAFoundation
//
//  Created by Zhu,Yusong on 2019/3/25.
//  Copyright © 2019年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (CommonExtension)

/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic, setter=bba_setLeft:) CGFloat bba_left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic, setter=bba_setTop:) CGFloat bba_top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic, setter=bba_setRight:) CGFloat bba_right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic, setter=bba_setBottom:) CGFloat bba_bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic, setter=bba_setWidth:) CGFloat bba_width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic, setter=bba_setHeight:) CGFloat bba_height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic, setter=bba_setCenterX:) CGFloat bba_centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic, setter=bba_setCenterY:) CGFloat bba_centerY;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic, setter=bba_setOrigin:) CGPoint bba_origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic, setter=bba_setSize:) CGSize bba_size;

@end
