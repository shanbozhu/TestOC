//
//  PBCollectionViewWaterfallLayout.m
//  TestOC
//
//  Created by shanbo on 2022/4/23.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCollectionViewWaterfallLayout.h"

// 默认的列数
static const NSInteger defaultColCount = 3;

// 每一列之间的间距
static const CGFloat defaultColMargin = 15;

// 每一行之间的间距
static const CGFloat defaultRowMargin = 10;

// 边缘间距
static const UIEdgeInsets defaultEdgeInsets = {20, 10, 20, 10};

@interface PBCollectionViewWaterfallLayout ()

// 存放所有cell的布局属性
@property (nonatomic, strong) NSMutableArray *attrsArray;
// 存放所有列的当前高度
@property (nonatomic, strong) NSMutableArray *colHeights;
/** 内容的高度 */
@property (nonatomic, assign) CGFloat contentHeight;

- (CGFloat)rowMargin;
- (CGFloat)colMargin;
- (NSInteger)colCount;
- (UIEdgeInsets)edgeInsets;

@end

@implementation PBCollectionViewWaterfallLayout

- (CGFloat)rowMargin {
    if ([self.delegate respondsToSelector:@selector(rowMarginInPBCollectionViewWaterfallLayout:)]) {
        return [self.delegate rowMarginInPBCollectionViewWaterfallLayout:self];
    } else {
        return defaultRowMargin;
    }
}

- (CGFloat)colMargin {
    if ([self.delegate respondsToSelector:@selector(colMarginInPBCollectionViewWaterfallLayout:)]) {
        return [self.delegate colMarginInPBCollectionViewWaterfallLayout:self];
    } else {
        return defaultColMargin;
    }
}

- (NSInteger)colCount {
    if ([self.delegate respondsToSelector:@selector(colCountInPBCollectionViewWaterfallLayout:)]) {
        return [self.delegate colCountInPBCollectionViewWaterfallLayout:self];
    } else {
        return defaultColCount;
    }
}

- (UIEdgeInsets)edgeInsets {
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInPBCollectionViewWaterfallLayout:)]) {
        return [self.delegate edgeInsetsInPBCollectionViewWaterfallLayout:self];
    } else {
        return defaultEdgeInsets;
    }
}

- (NSMutableArray *)attrsArray {
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (NSMutableArray *)colHeights {
    if (!_colHeights) {
        _colHeights = [NSMutableArray array];
    }
    return _colHeights;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    self.contentHeight = 0;
    
    //清除之前计算的所有高度，因为刷新的时候回调用这个方法
    [self.colHeights removeAllObjects];
    for (NSInteger i = 0; i < self.colCount; i++) {
        [self.colHeights addObject:@(self.edgeInsets.top)];
    }
    
    //把初始化的操作都放到这里
    [self.attrsArray removeAllObjects];
    
    //开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i++) {
        // 创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    
    CGFloat w = (collectionViewW - self.edgeInsets.left - self.edgeInsets.right -(self.colCount - 1) * self.colMargin) / self.colCount;
    
    CGFloat h = [self.delegate PBCollectionViewWaterfallLayout:self heightForRowAtIndexPath:indexPath.item itemWidth:w];
    
    NSInteger destcol = 0;
    
    CGFloat mincolHeight = [self.colHeights[0] doubleValue];
    for (NSInteger i = 0; i < self.colCount; i++) {
        CGFloat colHeight = [self.colHeights[i] doubleValue];
        
        if (mincolHeight > colHeight) {
            mincolHeight = colHeight;
            destcol = i;
        }
    }
    
    CGFloat x = self.edgeInsets.left + destcol * (w + self.colMargin);
    CGFloat y = mincolHeight;
    if (y != self.edgeInsets.top) {
        y += self.rowMargin;
    }
    
    attrs.frame = CGRectMake(x, y, w, h);
    
    self.colHeights[destcol] = @(CGRectGetMaxY(attrs.frame));
    
    CGFloat colHeight = [self.colHeights[destcol] doubleValue];
    if (self.contentHeight < colHeight) {
        self.contentHeight = colHeight;
    }
    return attrs;
    
}

- (CGSize)collectionViewContentSize {
//    CGFloat maxcolHeight = [self.colHeights[0] doubleValue];
//
//    for (NSInteger i = 1; i < defaultColCount; i++) {
//        // 取得第i列的高度
//        CGFloat colHeight = [self.colHeights[i] doubleValue];
//
//        if (maxcolHeight < colHeight) {
//            maxcolHeight = colHeight;
//        }
//    }
    return CGSizeMake(0, self.contentHeight + self.edgeInsets.bottom);
}

@end
