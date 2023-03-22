//
//  PBSeatButton.m
//  TestOC
//
//  Created by DaMaiIOS on 17/8/11.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBSeatButton.h"

#define kPBBtnImageViewScale 0.95

@implementation PBSeatButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat btnImageViewScale = kPBBtnImageViewScale;
    CGFloat btnImageViewX = (self.frame.size.width-self.frame.size.width*btnImageViewScale) * 0.5;
    CGFloat btnImageViewY = (self.frame.size.height-self.frame.size.height*btnImageViewScale) * 0.5;
    CGFloat btnImageViewW = self.frame.size.width * btnImageViewScale;
    CGFloat btnImageViewH = self.frame.size.height * btnImageViewScale;
    self.imageView.frame = CGRectMake(btnImageViewX, btnImageViewY, btnImageViewW, btnImageViewH);
}

@end
