//
//  UIView+CommonExtension.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/3/25.
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
@property (nonatomic, setter=pb_setLeft:) CGFloat pb_left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic, setter=pb_setTop:) CGFloat pb_top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic, setter=pb_setRight:) CGFloat pb_right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic, setter=pb_setBottom:) CGFloat pb_bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic, setter=pb_setWidth:) CGFloat pb_width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic, setter=pb_setHeight:) CGFloat pb_height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic, setter=pb_setCenterX:) CGFloat pb_centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic, setter=pb_setCenterY:) CGFloat pb_centerY;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic, setter=pb_setOrigin:) CGPoint pb_origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic, setter=pb_setSize:) CGSize pb_size;

@end
