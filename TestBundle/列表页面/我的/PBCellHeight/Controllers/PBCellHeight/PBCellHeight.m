//
//  PBCellHeight.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/6/15.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import "PBCellHeight.h"
#import <objc/runtime.h>

@protocol PBCellHeightDelegate <NSObject>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface PBCellHeight ()

@property (nonatomic, weak) id<PBCellHeightDelegate> delegate;

@property (nonatomic, strong) PBCellHeightBlock block;

@end

@implementation PBCellHeight

+ (CGFloat)cellHeightWithTarget:(id)target andTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    PBCellHeight *cellHeight = [[PBCellHeight alloc]init];
    cellHeight.delegate = target;
    
    //计算用cell,用完即释放
    UITableViewCell *cell = [cellHeight.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell removeFromSuperview];
    
    return CGRectGetHeight(cell.frame);
}

+ (CGFloat)cellHeightFitWithTarget:(id)target andTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    PBCellHeight *cellHeight = [[PBCellHeight alloc]init];
    cellHeight.delegate = target;
    
    //计算用cell,用完即释放
    UITableViewCell *cell = [cellHeight.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell removeFromSuperview];
    
    CGFloat max = 0;
    for (int i = 0; i < cell.contentView.subviews.count; i++) {
        UIView *view = cell.contentView.subviews[i];
        if (max < CGRectGetMaxY(view.frame)) {
            max = CGRectGetMaxY(view.frame);
        }
    }
    cell.pb_height = max;
    
    return CGRectGetHeight(cell.frame);
}

+ (CGFloat)cellHeightWithIdentifier:(NSString *)identifier andTableView:(UITableView *)tableView andCellClassName:(NSString *)cellClassName configuration:(PBCellHeightBlock)block {
    PBCellHeight *cellHeight = [[PBCellHeight alloc]init];
    cellHeight.block = block;
    
    //计算用cell,只有一个.tableView被释放,计算用cell则被释放
    NSMutableDictionary *cellList = objc_getAssociatedObject(tableView, _cmd);
    if (cellList == nil) {
        cellList = @{}.mutableCopy;
        objc_setAssociatedObject(tableView, _cmd, cellList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UITableViewCell *cell = cellList[identifier];
    if (cell == nil) {
        [tableView registerClass:NSClassFromString(cellClassName) forCellReuseIdentifier:identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cellList[identifier] = cell;
    }
    
    cellHeight.block(cell);
    
    cell.pb_height = [cell sizeThatFits:cell.frame.size].height;
    
    return CGRectGetHeight(cell.frame);
}

+ (CGFloat)cellHeightFitWithIdentifier:(NSString *)identifier andTableView:(UITableView *)tableView andCellClassName:(NSString *)cellClassName configuration:(PBCellHeightBlock)block {
    PBCellHeight *cellHeight = [[PBCellHeight alloc]init];
    cellHeight.block = block;
    
    //计算用cell,只有一个.tableView被释放,计算用cell则被释放
    NSMutableDictionary *cellList = objc_getAssociatedObject(tableView, _cmd);
    if (cellList == nil) {
        cellList = @{}.mutableCopy;
        objc_setAssociatedObject(tableView, _cmd, cellList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UITableViewCell *cell = cellList[identifier];
    if (cell == nil) {
        [tableView registerClass:NSClassFromString(cellClassName) forCellReuseIdentifier:identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cellList[identifier] = cell;
    }
    
    cellHeight.block(cell);
    
    CGFloat max = 0;
    for (int i = 0; i < cell.contentView.subviews.count; i++) {
        UIView *view = cell.contentView.subviews[i];
        if (max < CGRectGetMaxY(view.frame)) {
            max = CGRectGetMaxY(view.frame);
        }
    }
    cell.pb_height = max;
    
    return CGRectGetHeight(cell.frame);
}

- (void)dealloc {
    //NSLog(@"PBCellHeight对象被释放了");
}

@end

/** UIView分类 */
@implementation UIView (PBCellHeight)

// 视图宽度
- (CGFloat)pb_width {
    return self.frame.size.width;
}

- (void)setPb_width:(CGFloat)pb_width {
    CGRect rect = self.frame;
    rect.size.width = pb_width;
    self.frame = rect;
}

// 视图高度
- (CGFloat)pb_height {
    return self.frame.size.height;
}

- (void)setPb_height:(CGFloat)pb_height {
    CGRect rect = self.frame;
    rect.size.height = pb_height;
    self.frame = rect;
}

@end

/** NSString分类 */
@implementation NSString (PBCellHeight)

// 判断是否含有中文
- (BOOL)pb_containChinese:(NSString *)str {
    for (int i = 0; i < str.length; i++) {
        int a = [str characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

// 显示全部内容的文本高度
- (CGSize)pb_boundingSizeWithWidth:(CGFloat)width andFont:(UIFont *)font andLineSpacing:(CGFloat)lineSpacing {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self];
    
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.length)];
    
    if (lineSpacing > 0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = lineSpacing;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.length)];
    }
        
    UILabel *lab = [[UILabel alloc]init];
    lab.numberOfLines = 0;
    lab.frame = CGRectMake(0, 0, width, 0);
    lab.attributedText = attributedString;
    [lab sizeToFit];
    
    CGRect rect;
    rect.size.width = lab.frame.size.width;
    rect.size.height = lab.frame.size.height;
    
    //系统字体显示一行且含有中文的时候会显示行间距
    if (([font.fontName isEqualToString:@".SFUIText"] || [font.fontName isEqualToString:@".SFUIDisplay"]) && rect.size.height < (font.lineHeight * 2 + lineSpacing) && [self pb_containChinese:self]) {
        return CGSizeMake(rect.size.width, rect.size.height - lineSpacing);
    }
    
    return rect.size;
}

// 显示至多numberOfLines内容的文本高度
- (CGSize)pb_boundingSizeWithWidth:(CGFloat)width andFont:(UIFont *)font andLineSpacing:(CGFloat)lineSpacing andNumberOfLines:(NSInteger)numberOfLines {
    if (numberOfLines <= 0) {
        CGSize size = [self pb_boundingSizeWithWidth:width andFont:font andLineSpacing:lineSpacing];
        return CGSizeMake(size.width, ceilf(size.height));
    }
    
    //最大高度
    CGFloat maxHeight = numberOfLines * font.lineHeight + (numberOfLines - 1) * lineSpacing;
    
    CGSize size = [self pb_boundingSizeWithWidth:width andFont:font andLineSpacing:lineSpacing];
    
    if (size.height > maxHeight) {
        return CGSizeMake(size.width, ceilf(maxHeight));
    } else {
        return CGSizeMake(size.width, ceilf(size.height));
    }
}

@end
