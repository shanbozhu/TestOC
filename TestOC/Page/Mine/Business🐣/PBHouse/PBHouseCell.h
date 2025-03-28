//
//  PBHouseCell.h
//  TestOC
//
//  Created by zhushanbo on 2025/3/28.
//  Copyright © 2025 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBHouse.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBHouseCell : UITableViewCell

@property (nonatomic, strong) PBHouseShowData *showData;

+ (instancetype)houseCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
