//
//  PBChannelContentView.m
//  PBTest
//
//  Created by DaMaiIOS on 17/5/25.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import "PBChannelContentView.h"
#import "PBChannelContentCell.h"

@interface PBChannelContentView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation PBChannelContentView

+ (id)channelContentViewWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
        self.collectionView = collectionView;
        [self addSubview:collectionView];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.pagingEnabled = YES;
    }
    return self;
}

- (void)setChannelArr:(NSArray *)channelArr {
    _channelArr = channelArr;
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.channelArr.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBChannelContentCell *cell = [PBChannelContentCell channelContentCellWithCollectionView:collectionView indexPath:indexPath];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell.vc removeFromParentViewController];
    
    UIViewController *vc = [self.delegate channelContentView:self pageView:cell.contentView index:indexPath.item];
    cell.vc = vc;
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.delegate channelContentView:self offset:scrollView.contentOffset];
}

- (void)setContentOffsetWithIndex:(NSInteger)index {
    [self.collectionView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width * index, 0) animated:NO];
}

@end
