//
//  PBYYTextTableView.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/26.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBYYTextTableView.h"

@implementation PBYYTextTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.delaysContentTouches = NO;
        self.canCancelContentTouches = YES;
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
