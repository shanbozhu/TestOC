//
//  PBCellHeightThreeCell.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBCellHeightZeroData.h"

@interface PBCellHeightThreeCell : UITableViewCell

@property (nonatomic, strong) PBCellHeightZeroData *testListData;

+ (id)testListThreeCellWithTableView:(UITableView *)tableView;

@end
