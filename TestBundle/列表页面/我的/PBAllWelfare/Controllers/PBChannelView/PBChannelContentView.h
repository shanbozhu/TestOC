//
//  PBChannelContentView.h
//  PBTest
//
//  Created by DaMaiIOS on 17/5/25.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBChannelContentView;
@protocol PBChannelContentViewDelegate <NSObject>

-(UIViewController *)channelContentView:(PBChannelContentView *)channelContentView andPageView:(UIView *)pageView andIndex:(NSInteger)index;

-(void)channelContentView:(PBChannelContentView *)channelContentView andOffset:(CGPoint)offset;

@end

@interface PBChannelContentView : UIView

@property(nonatomic, strong)NSArray *channelArr;

@property(nonatomic, weak)id <PBChannelContentViewDelegate> delegate;

+(id)channelContentViewWithFrame:(CGRect)frame;

-(void)setContentOffsetWithIndex:(NSInteger)index;

@end
