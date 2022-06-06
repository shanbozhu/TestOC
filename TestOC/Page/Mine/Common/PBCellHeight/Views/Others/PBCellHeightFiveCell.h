//
//  PBCellHeightFiveCell.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBCellHeightZeroData.h"

@interface PBCellHeightFiveCell : UITableViewCell

@property (nonatomic, strong) PBCellHeightZeroData *testListData;

+ (id)testListFiveCellWithTableView:(UITableView *)tableView;

@end
