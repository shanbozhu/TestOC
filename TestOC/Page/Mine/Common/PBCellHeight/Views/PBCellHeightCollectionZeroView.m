//
//  PBCellHeightCollectionZeroView.m
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightCollectionZeroView.h"
#import "PBCellHeightCollectionZeroCell.h"

@interface PBCellHeightCollectionZeroView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation PBCellHeightCollectionZeroView

+ (id)testListView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - APPLICATION_NAVIGATIONBAR_HEIGHT) collectionViewLayout:layout];
        self.collectionView = collectionView;
        [self addSubview:collectionView];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (void)setTestList:(PBCellHeightZero *)testList {
    _testList = testList;
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.testList.data.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    {
        PBCellHeightZeroData *testListData = self.testList.data[indexPath.item];
        PBCellHeightZeroData *testListDataAdjacent = nil;
        if (indexPath.item % 2 == 0) {
            if (indexPath.item + 1 <= self.testList.data.count - 1) {
                testListDataAdjacent = self.testList.data[indexPath.item + 1];
            }
        } else {
            testListDataAdjacent = self.testList.data[indexPath.item - 1];
        }
    }
    
    // 当前cell高度
    UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    [cell removeFromSuperview];
    CGSize size = CGSizeMake(CGRectGetWidth(cell.frame), CGRectGetHeight(cell.frame));
    
    // 相邻cell高度
    CGSize sizeAdjacent = CGSizeZero;
    if (indexPath.item % 2 == 0) { // 偶数
        NSIndexPath *indexPathAdjacent = indexPath;
        if (indexPath.item + 1 <= self.testList.data.count - 1) {
            indexPathAdjacent = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:0];
        }
        UICollectionViewCell *cellAdjacent = [self collectionView:collectionView cellForItemAtIndexPath:indexPathAdjacent];
        [cellAdjacent removeFromSuperview];
        sizeAdjacent = CGSizeMake(CGRectGetWidth(cellAdjacent.frame), CGRectGetHeight(cellAdjacent.frame));
    } else { // 奇数
        NSIndexPath *indexPathAdjacent = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:0];
        UICollectionViewCell *cellAdjacent = [self collectionView:collectionView cellForItemAtIndexPath:indexPathAdjacent];
        [cellAdjacent removeFromSuperview];
        sizeAdjacent = CGSizeMake(CGRectGetWidth(cellAdjacent.frame), CGRectGetHeight(cellAdjacent.frame));
    }
    
    CGFloat cellHeightForPerRow = size.height; // 同一行取最大cell的高度
    if (size.height < sizeAdjacent.height) {
        cellHeightForPerRow = sizeAdjacent.height;
    }
    return CGSizeMake(size.width, cellHeightForPerRow);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightCollectionZeroCell *cell = [PBCellHeightCollectionZeroCell testListCellWithCollectionView:collectionView indexPath:indexPath];
    cell.testListData = self.testList.data[indexPath.item];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 13, 15, 13);
}

@end
