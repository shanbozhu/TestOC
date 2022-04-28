//
//  PBCycleCollectionView.m
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCycleCollectionView.h"
#import "PBCycleCell.h"
#import "PBCollectionViewWaterfallLayout.h"

@interface PBCycleCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PBCollectionViewWaterfallLayoutDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation PBCycleCollectionView

+ (id)testListView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        PBCollectionViewWaterfallLayout *layout = [[PBCollectionViewWaterfallLayout alloc] init];
        layout.delegate = self;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - APPLICATION_NAVIGATIONBAR_HEIGHT - APPLICATION_SAFE_AREA_BOTTOM_MARGIN) collectionViewLayout:layout];
        self.collectionView = collectionView;
        [self addSubview:collectionView];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        collectionView.layer.borderColor = [UIColor blueColor].CGColor;
        collectionView.layer.borderWidth = 1.1;
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCycleCell *cell = [PBCycleCell testListCellWithCollectionView:collectionView indexPath:indexPath];
    cell.index = indexPath.item;
    cell.testListData = self.testList.data[indexPath.item];
    return cell;
}

#pragma mark - PBCollectionViewWaterfallLayoutDelegate
- (CGFloat)collectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout heightForRowAtIndexPath:(NSInteger)index itemWidth:(CGFloat)itemWidth {
    return itemWidth * (1 + arc4random_uniform(3));
}

- (CGFloat)colCountInCollectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout {
    return 4;
}

- (CGFloat)colMarginInCollectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout {
    return 15;
}

- (CGFloat)rowMarginInCollectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout {
    return 20;
}

- (UIEdgeInsets)edgeInsetsInCollectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout {
    return UIEdgeInsetsMake(30, 15, 30, 15);
}

@end
