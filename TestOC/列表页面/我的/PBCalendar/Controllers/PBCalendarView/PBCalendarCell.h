//
//  PBCalendarCell.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/4/20.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBCalendarCell : UICollectionViewCell

@property (nonatomic, weak) UILabel *lab;

+ (id)calendarCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
