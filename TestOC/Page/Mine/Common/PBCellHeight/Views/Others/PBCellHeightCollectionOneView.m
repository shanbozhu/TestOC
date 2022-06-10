//
//  PBCellHeightCollectionOneView.m
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightCollectionOneView.h"
#import "PBCellHeightCollectionOneCell.h"
#import "PBCollectionViewWaterfallLayout.h"
#import "PBRefresh.h"

@interface PBCellHeightCollectionOneView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PBCollectionViewWaterfallLayoutDelegate>

@end

@implementation PBCellHeightCollectionOneView

+ (id)testListView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //
        PBCollectionViewWaterfallLayout *Waterfalllayout = [[PBCollectionViewWaterfallLayout alloc] init];
        Waterfalllayout.delegate = self;
        self.collectionView.collectionViewLayout = Waterfalllayout;
        
        // 刷新
        __weak typeof(self) weakSelf = self;
        self.collectionView.mj_header = [PBRefresh refreshHeaderWithTarget:self refreshingBlock:^(PBRefresh *refresh) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.delegate cellHeightCollectionOneView:strongSelf sinceId:0 status:0];
        }];
        self.collectionView.mj_footer = [PBRefresh refreshFooterWithTarget:self refreshingBlock:^(PBRefresh *refresh) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSInteger sinceId = 1000; // 提供个假值
            [strongSelf.delegate cellHeightCollectionOneView:strongSelf sinceId:sinceId status:1];
        }];
    }
    return self;
}

- (void)setTestList:(PBCellHeightZero *)testList {
    _testList = testList;
    [self.collectionView reloadData];
    
    // 刷新
    [self.collectionView.mj_header endRefreshing];
    if (self.testList.dataAddIsNull) {
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.collectionView.mj_footer endRefreshing];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.testList.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightCollectionOneCell *cell = [PBCellHeightCollectionOneCell testListCellWithCollectionView:collectionView indexPath:indexPath];
    cell.index = indexPath.item;
    cell.testListData = self.testList.data[indexPath.item];
    return cell;
}

#pragma mark - PBCollectionViewWaterfallLayoutDelegate

// required
- (CGFloat)collectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout heightForRowAtIndexPath:(NSInteger)index itemWidth:(CGFloat)itemWidth {
    return itemWidth * (1 + arc4random_uniform(3));
}

- (CGFloat)colCountInCollectionViewWaterfallLayout:(PBCollectionViewWaterfallLayout *)PBCollectionViewWaterfallLayout {
    return 3;
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
