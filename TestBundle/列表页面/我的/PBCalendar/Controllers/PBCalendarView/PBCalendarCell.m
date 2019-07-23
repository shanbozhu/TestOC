//
//  PBCalendarCell.m
//  TestBundle
//
//  Created by DaMaiIOS on 2018/4/20.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCalendarCell.h"

@implementation PBCalendarCell

+ (id)calendarCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:@"PBCalendarCell"];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PBCalendarCell" forIndexPath:indexPath];
    return cell;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *lab = [[UILabel alloc]init];
        [self.contentView addSubview:lab];
        lab.frame = self.bounds;
        lab.textAlignment = NSTextAlignmentCenter;
        self.lab = lab;
    }
    return self;
}

@end
