//
//  PBCellHeight.h
//  TestOC
//
//  Created by DaMaiIOS on 17/6/15.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (PBCellHeight)

/// UILabel接收字符串计算高度
- (CGSize)pb_boundingSizeWithWidth:(CGFloat)width andFont:(UIFont *)font andLineSpacing:(CGFloat)lineSpacing andNumberOfLines:(NSInteger)numberOfLines;

@end
