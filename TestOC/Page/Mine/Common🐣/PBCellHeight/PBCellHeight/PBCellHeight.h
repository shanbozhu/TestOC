//
//  PBCellHeight.h
//  TestOC
//
//  Created by DaMaiIOS on 17/6/15.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 此框架适用于每次计算50以内的列表数据，数据太多可能导致计算耗时过长

@class PBCellHeight;
typedef void(^PBCellHeightBlock)(id tempCell);

@interface PBCellHeight : NSObject

/// cell包裹cell子视图之后还可以有剩余高度，需要在cell内单独设置cell高度
+ (CGFloat)cellHeightWithTarget:(id)target andTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

/// cell刚好包裹cell子视图
+ (CGFloat)cellHeightFitWithTarget:(id)target andTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

/// cell包裹cell子视图之后还可以有剩余高度，需要在cell内单独设置cell高度
+ (CGFloat)cellHeightWithIdentifier:(NSString *)identifier andTableView:(UITableView *)tableView andCellClassName:(NSString *)cellClassName configuration:(PBCellHeightBlock)block;

/// cell刚好包裹cell子视图
/// 注意：如果cellClassName的cell只有一个复用标志，则identifier可以传任意字符串；如果cellClassName的cell有多个复用标志，则identifier必须传与cellForRowAtIndexPath方法中相同的复用标志
+ (CGFloat)cellHeightFitWithIdentifier:(NSString *)identifier andTableView:(UITableView *)tableView andCellClassName:(NSString *)cellClassName configuration:(PBCellHeightBlock)block;

@end


@interface UIView (PBCellHeight)

/// 视图高度
@property (nonatomic, assign) CGFloat pb_height;
/// 视图宽度
@property (nonatomic, assign) CGFloat pb_width;

@end


@interface NSString (PBCellHeight)

/// UILabel接收字符串计算高度
- (CGSize)pb_boundingSizeWithWidth:(CGFloat)width andFont:(UIFont *)font andLineSpacing:(CGFloat)lineSpacing andNumberOfLines:(NSInteger)numberOfLines;

@end
