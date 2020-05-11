//
//  PBChannelContentCell.m
//  PBTest
//
//  Created by DaMaiIOS on 17/5/25.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import "PBChannelContentCell.h"

@implementation PBChannelContentCell

+ (id)channelContentCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:@"PBChannelContentCell"];
    PBChannelContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PBChannelContentCell" forIndexPath:indexPath];
    return cell;
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"PBChannelContentCell对象被释放了");
}

@end
