//
//  UIView+PBCommonExtension.h
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/3/25.
//  Copyright © 2019年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (PBCommonExtension)

@property (nonatomic, setter=pb_setLeft:) CGFloat pb_left;

@property (nonatomic, setter=pb_setTop:) CGFloat pb_top;

@property (nonatomic, setter=pb_setRight:) CGFloat pb_right;

@property (nonatomic, setter=pb_setBottom:) CGFloat pb_bottom;

@property (nonatomic, setter=pb_setWidth:) CGFloat pb_width;

@property (nonatomic, setter=pb_setHeight:) CGFloat pb_height;

@property (nonatomic, setter=pb_setCenterX:) CGFloat pb_centerX;

@property (nonatomic, setter=pb_setCenterY:) CGFloat pb_centerY;

@property (nonatomic, setter=pb_setOrigin:) CGPoint pb_origin;

@property (nonatomic, setter=pb_setSize:) CGSize pb_size;

@end
