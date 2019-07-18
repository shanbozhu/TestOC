//
//  PBChannelHeaderView.h
//  PBTest
//
//  Created by DaMaiIOS on 17/5/25.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBChannelHeaderView;
@protocol PBChannelHeaderViewDelegate <NSObject>

-(void)channelView:(PBChannelHeaderView *)channelView andIndex:(NSInteger)index;

@end

@interface PBChannelHeaderView : UIView


@property(nonatomic, strong)NSArray *channelArr;
@property(nonatomic, weak)id<PBChannelHeaderViewDelegate> delegate;

+(id)channelView;

-(void)setContentOffsetWithOffset:(CGPoint)offset;


@end
