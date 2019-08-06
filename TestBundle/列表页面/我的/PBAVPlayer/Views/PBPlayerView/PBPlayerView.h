//
//  PBPlayerView.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/1.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBPlayerView : UIView

@property(nonatomic, strong)UIColor *progressBackgroundColor;
@property(nonatomic, strong)UIColor *progressBufferColor;
@property(nonatomic, strong)UIColor *progressPlayFinishColor;


@property(nonatomic, copy)NSString *url;

+(id)playerViewWithFrame:(CGRect)frame;

-(void)playVideo;

@end
