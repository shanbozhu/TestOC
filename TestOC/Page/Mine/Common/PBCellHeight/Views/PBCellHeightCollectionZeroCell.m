//
//  PBCellHeightCollectionZeroCell.m
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightCollectionZeroCell.h"

@implementation PBCellHeightCollectionZeroCell

+ (id)testListCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:@"PBCellHeightCollectionZeroCell"];
    PBCellHeightCollectionZeroCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PBCellHeightCollectionZeroCell" forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

@end
