//
//  PBCellHeightFiveCellVM.m
//  TestOC
//
//  Created by shanbo on 2022/6/6.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFiveCellVM.h"
#import <YYText.h>

@interface PBCellHeightFiveCellVM ()

@end

@implementation PBCellHeightFiveCellVM

#pragma mark -
- (void)layoutInfoWithData:(PBCellHeightZeroData *)testListData {
    self.testListData = testListData;
    
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, CGFLOAT_MAX);
    
    //
    YYLabel *calLab = [[YYLabel alloc] init];
    calLab.frame = CGRectMake(0, 0, size.width, size.height);
    calLab.text = self.testListData.content;
    calLab.font = [UIFont systemFontOfSize:labFont];
    calLab.numberOfLines = 0;
    [calLab sizeToFit];
    self.labRect = CGRectMake(20, 20, calLab.frame.size.width, calLab.frame.size.height); // 提前将各控件的frame计算好
    
    //
    self.imageViewRect = CGRectMake(CGRectGetMinX(self.labRect), CGRectGetMaxY(self.labRect) + 10, 150, 50 * (1 + arc4random_uniform(3))); // 提前将各控件的frame计算好
    
    //
    self.cellHeight = CGRectGetMaxY(self.imageViewRect) + 20; // 提前将各控件的frame计算好
}

@end
