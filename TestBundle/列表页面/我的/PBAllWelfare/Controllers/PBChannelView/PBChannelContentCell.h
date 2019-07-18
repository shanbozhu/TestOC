//
//  PBChannelContentCell.h
//  PBTest
//
//  Created by DaMaiIOS on 17/5/25.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBChannelContentCell : UICollectionViewCell

@property (nonatomic, weak) UIViewController *vc;

+ (id)channelContentCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;

@end
