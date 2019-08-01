//
//  PBCellHeightTwoCell.h
//  TestBundle
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBCellHeightZeroData.h"

@interface PBCellHeightTwoCell : UITableViewCell

@property(nonatomic, strong)PBCellHeightZeroData *testListData;

+(id)testListTwoCellWithTableView:(UITableView *)tableView;

@end
