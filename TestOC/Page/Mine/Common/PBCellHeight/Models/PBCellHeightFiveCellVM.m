//
//  PBCellHeightFiveCellVM.m
//  TestOC
//
//  Created by shanbo on 2022/6/6.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFiveCellVM.h"
#import <YYText.h>
#import "PBCellHeightZeroData.h"

@interface PBCellHeightFiveCellVM ()

@property (nonatomic, strong) PBCellHeightZeroData *testListData;

@end

@implementation PBCellHeightFiveCellVM

- (void)layoutInfoWithData:(PBCellHeightZeroData *)testListData {
    self.testListData = testListData;
    
    //
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, CGFLOAT_MAX);
    
    //
    YYLabel *calLab = [[YYLabel alloc] init];
    calLab.frame = CGRectMake(0, 0, size.width, size.height);
    calLab.text = self.testListData.content;
    calLab.font = [UIFont systemFontOfSize:labFont];
    calLab.numberOfLines = 0;
    [calLab sizeToFit];
    self.labRect = CGRectMake(20, 20, calLab.frame.size.width, calLab.frame.size.height);
    
    //
    self.imageViewRect = CGRectMake(CGRectGetMinX(self.labRect), CGRectGetMaxY(self.labRect) + 10, 150, 50 * (1 + arc4random_uniform(3)));
    
    //
    self.cellHeight = CGRectGetMaxY(self.imageViewRect) + 20;
}

- (void)dealloc {
    NSLog(@"PBCellHeightFiveCellVM对象被释放了");
}

@end
