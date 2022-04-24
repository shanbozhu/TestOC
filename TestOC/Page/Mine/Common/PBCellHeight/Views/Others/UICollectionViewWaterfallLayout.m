//
//  UICollectionViewWaterfallLayout.m
//  TestOC
//
//  Created by shanbo on 2022/4/23.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "UICollectionViewWaterfallLayout.h"


@implementation UICollectionViewWaterfallLayout{
    NSMutableArray * attributeArray; // frame 数组
    NSInteger _collectViewRowCount;  // 列数
    NSMutableArray * _originYAry;    //记录每一列的Y点坐标
}
 
 
- (instancetype)init
{
    self = [super init];
    if (self) {
        attributeArray = [NSMutableArray array];
        _originYAry = [NSMutableArray array];
        _collectViewRowCount = 3;
    }
    return self;
}
 
//1.告诉当前layout对象，更新当前布局
- (void)prepareLayout{
    
    [attributeArray removeAllObjects];
    [_originYAry removeAllObjects];
    
    //初始化y坐标
    for (int i =0; i <_collectViewRowCount; i++) {
        [_originYAry addObject:@(0)];
    }
    
    //返回
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
        
    for (int i = 0; i < cellCount; i ++ ) {
            
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            
        //UICollectionViewLayoutAttributes 用于存储layout属性的对象
        UICollectionViewLayoutAttributes *attrib = [self layoutAttributesForItemAtIndexPath:indexPath];
            
        [attributeArray addObject:attrib];
    }
}
 
//2.返回指定indexPath下的 UICollectionViewLayoutAttributes
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //根据indexPath创建一个UICollectionViewLayoutAttributes
    UICollectionViewLayoutAttributes *layoutAttr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //设置每个frame
    CGFloat width = [UIScreen mainScreen].bounds.size.width /_collectViewRowCount;
    CGFloat height = 50 + arc4random_uniform(20);
    CGFloat x = width * ( indexPath.row % _collectViewRowCount);
    
    CGFloat y = [_originYAry[indexPath.row % _collectViewRowCount] floatValue];
    _originYAry[indexPath.row % _collectViewRowCount] = @(height + y +10);
    layoutAttr.frame =CGRectMake(x, y, width, height);
    
    return layoutAttr;
}
 
//3.返回collectionView的ContentSize
//由于瀑布流每一列的高度不一定，所以需要判读出最高的列作为height
-(CGSize)collectionViewContentSize{
    
    //kvc 获取最大值
    CGFloat maxY =[[_originYAry valueForKeyPath:@"@max.floatValue"] floatValue];
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, maxY);
}
 
//4.Returns the layout attributes for all of the cells and views in the specified rectangle.
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    return attributeArray;
}



@end
