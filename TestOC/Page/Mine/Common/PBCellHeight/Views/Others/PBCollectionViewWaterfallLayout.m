//
//  PBCollectionViewWaterfallLayout.m
//  TestOC
//
//  Created by shanbo on 2022/4/23.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCollectionViewWaterfallLayout.h"

static const NSInteger defaultColCount = 3; // 列数
static const CGFloat defaultColMargin = 15; // 每一列之间的间距
static const CGFloat defaultRowMargin = 10; // 每一行之间的间距
static const UIEdgeInsets defaultEdgeInsets = {20, 10, 20, 10}; // 内边距

@interface PBCollectionViewWaterfallLayout ()

@property (nonatomic, strong) NSMutableArray *attrsArr; // 所有cell的布局属性
@property (nonatomic, strong) NSMutableArray *colHeights; // 所有列的当前高度

- (CGFloat)rowMargin;
- (CGFloat)colMargin;
- (NSInteger)colCount;
- (UIEdgeInsets)edgeInsets;

@end

@implementation PBCollectionViewWaterfallLayout

#pragma mark -
- (CGFloat)rowMargin {
    if ([self.delegate respondsToSelector:@selector(rowMarginInCollectionViewWaterfallLayout:)]) {
        return [self.delegate rowMarginInCollectionViewWaterfallLayout:self];
    } else {
        return defaultRowMargin;
    }
}

- (CGFloat)colMargin {
    if ([self.delegate respondsToSelector:@selector(colMarginInCollectionViewWaterfallLayout:)]) {
        return [self.delegate colMarginInCollectionViewWaterfallLayout:self];
    } else {
        return defaultColMargin;
    }
}

- (NSInteger)colCount {
    if ([self.delegate respondsToSelector:@selector(colCountInCollectionViewWaterfallLayout:)]) {
        return [self.delegate colCountInCollectionViewWaterfallLayout:self];
    } else {
        return defaultColCount;
    }
}

- (UIEdgeInsets)edgeInsets {
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInCollectionViewWaterfallLayout:)]) {
        return [self.delegate edgeInsetsInCollectionViewWaterfallLayout:self];
    } else {
        return defaultEdgeInsets;
    }
}

#pragma mark -
- (NSMutableArray *)attrsArr {
    if (!_attrsArr) {
        _attrsArr = [NSMutableArray array];
    }
    return _attrsArr;
}

- (NSMutableArray *)colHeights {
    if (!_colHeights) {
        _colHeights = [NSMutableArray array];
    }
    return _colHeights;
}

// 刷新的时候回调用这个方法
- (void)prepareLayout {
    [super prepareLayout];
        
    [self.colHeights removeAllObjects];
    for (NSInteger i = 0; i < self.colCount; i++) {
        [self.colHeights addObject:@(self.edgeInsets.top)];
    }
    [self.attrsArr removeAllObjects];
    
    // 开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArr addObject:attrs];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 根据indexPath创建每一个cell的布局属性
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    CGFloat w = (collectionViewW - self.edgeInsets.left - self.edgeInsets.right - (self.colCount - 1) * self.colMargin) / self.colCount;
    CGFloat h = [self.delegate collectionViewWaterfallLayout:self heightForRowAtIndexPath:indexPath.item itemWidth:w];
    
    NSInteger destCol = 0;
    CGFloat minColHeight = [self.colHeights[0] doubleValue]; // 每次默认从第0列开始,默认第0列最短
    for (NSInteger i = 0; i < self.colCount; i++) {
        CGFloat colHeight = [self.colHeights[i] doubleValue];
        if (colHeight < minColHeight) {
            minColHeight = colHeight;
            destCol = i;
        }
    }
    
    CGFloat x = self.edgeInsets.left + destCol * (w + self.colMargin);
    CGFloat y = minColHeight;
    if (y != self.edgeInsets.top) {
        y += self.rowMargin;
    }
    attrs.frame = CGRectMake(x, y, w, h); // 设置布局属性的frame
    
    self.colHeights[destCol] = @(CGRectGetMaxY(attrs.frame));
    
    return attrs;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArr;
}

- (CGSize)collectionViewContentSize {
    CGFloat maxColHeight = [self.colHeights[0] doubleValue];
    for (NSInteger i = 0; i < self.colCount; i++) {
        CGFloat colHeight = [self.colHeights[i] doubleValue];
        if (colHeight > maxColHeight) {
            maxColHeight = colHeight;
        }
    }
    return CGSizeMake(0, maxColHeight + self.edgeInsets.bottom);
}

@end
