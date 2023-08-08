//
//  PBCellHeightCollectionOneCell.h
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBCellHeightZeroData.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBCellHeightCollectionOneCell : UICollectionViewCell

@property (nonatomic, strong) PBCellHeightZeroData *testListData;
@property (nonatomic, assign) NSInteger index;

+ (id)testListCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
