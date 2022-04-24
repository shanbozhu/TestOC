//
//  UICollectionViewWaterfallLayout.m
//  TestOC
//
//  Created by shanbo on 2022/4/23.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "UICollectionViewWaterfallLayout.h"

@interface UICollectionViewWaterfallLayout ()

@property (nonatomic, strong) NSMutableArray *attributeArr; // frame 数组
@property (nonatomic, assign) NSInteger colCount; // 列数
@property (nonatomic, strong) NSMutableArray *originYArr; //记录每一列的Y点坐标

@end

@implementation UICollectionViewWaterfallLayout

- (instancetype)init {
    if (self = [super init]) {
        self.attributeArr = [NSMutableArray array];
        self.originYArr = [NSMutableArray array];
        self.colCount = 3;
    }
    return self;
}

// 1.告诉当前layout对象，更新当前布局
- (void)prepareLayout {
    [self.attributeArr removeAllObjects];
    [self.originYArr removeAllObjects];
    
    //初始化y坐标
    for (int i = 0; i < self.colCount; i++) {
        [self.originYArr addObject:@(0)];
    }
    
    //返回
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < cellCount; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        //UICollectionViewLayoutAttributes 用于存储layout属性的对象
        UICollectionViewLayoutAttributes *attrib = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attributeArr addObject:attrib];
    }
}

// 2.返回指定indexPath下的 UICollectionViewLayoutAttributes
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 根据indexPath创建一个UICollectionViewLayoutAttributes
    UICollectionViewLayoutAttributes *layoutAttr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 设置每个frame
    CGFloat width = [UIScreen mainScreen].bounds.size.width / self.colCount;
    CGFloat height = 50 + arc4random_uniform(20);
    CGFloat x = width * (indexPath.row % self.colCount);
    
    CGFloat y = [self.originYArr[indexPath.row % self.colCount] floatValue];
    self.originYArr[indexPath.row % self.colCount] = @(height + y + 10);
    layoutAttr.frame = CGRectMake(x, y, width, height);
    return layoutAttr;
}

// 3.返回collectionView的ContentSize
// 由于瀑布流每一列的高度不一定，所以需要判读出最高的列作为height
- (CGSize)collectionViewContentSize {
    // kvc获取最大值
    CGFloat maxY = [[self.originYArr valueForKeyPath:@"@max.floatValue"] floatValue];
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, maxY);
}

// 4.Returns the layout attributes for all of the cells and views in the specified rectangle.
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributeArr;
}

@end
