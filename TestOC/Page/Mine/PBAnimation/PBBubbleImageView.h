//
//  PBBubbleImageView.h
//  TestOC
//
//  Created by shanbo on 2021/11/12.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBAnimationBubbleView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBBubbleImageView : UIImageView

@property (nonatomic, weak) PBAnimationBubbleView *bubbleView;

@end

NS_ASSUME_NONNULL_END
