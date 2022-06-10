//
//  PBCellHeightCollectionBaseView.m
//  TestOC
//
//  Created by shanbo on 2022/6/10.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightCollectionBaseView.h"

@interface PBCellHeightCollectionBaseView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation PBCellHeightCollectionBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
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

@end
