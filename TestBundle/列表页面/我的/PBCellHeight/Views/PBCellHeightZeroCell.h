//
//  PBCellHeightZeroCell.h
//  TestBundle
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBCellHeightZeroData.h"

@interface PBCellHeightZeroCell : UITableViewCell

@property (nonatomic, strong) PBCellHeightZeroData *testListData;

+ (id)testListCellWithTableView:(UITableView *)tableView;

@end
