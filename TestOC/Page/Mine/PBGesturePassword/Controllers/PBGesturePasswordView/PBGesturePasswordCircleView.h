//
//  PBGesturePasswordCircleView.h
//  TestOC
//
//  Created by DaMaiIOS on 17/9/5.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

// 圆所处类型
enum CircleType {
    CircleTypeInfo,
    CircleTypeGesture,
};
typedef enum CircleType kPBCircleType;

// 圆所在状态
enum CircleState {
    CircleStateNormal,
    CircleStateSelected,
    CircleStateError,
    CircleStateLastOneSelected,
    CircleStateLastOneError,
};
typedef enum CircleState kPBCircleState;

@interface PBGesturePasswordCircleView : UIView

@property (nonatomic, assign) kPBCircleType circleType;
@property (nonatomic, assign) kPBCircleState circleState;
@property (nonatomic, assign) CGFloat angle;

@end
