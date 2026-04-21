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

@end

@implementation PBCellHeightFiveCellVM

- (void)layoutInfoWithData:(PBCellHeightZeroData *)testListData {
    // 注意：当前是在子线程计算，一定不能出现 UI 逻辑。
    // 在子线程，提前计算各控件frame，然后赋值给属性。
    
    //
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, CGFLOAT_MAX);
    
    //
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:testListData.content];
    [attStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:labFont]} range:NSMakeRange(0, testListData.content.length)];
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attStr];
    self.labRect = CGRectMake(20, 20, layout.textBoundingSize.width, layout.textBoundingSize.height);
    
    //
    self.imageViewRect = CGRectMake(CGRectGetMinX(self.labRect), CGRectGetMaxY(self.labRect) + 10, 150, 50 * (1 + arc4random_uniform(3)));
    
    //
    self.cellHeight = CGRectGetMaxY(self.imageViewRect) + 20;
}

- (void)dealloc {
    NSLog(@"PBCellHeightFiveCellVM对象被释放了");
}

@end
