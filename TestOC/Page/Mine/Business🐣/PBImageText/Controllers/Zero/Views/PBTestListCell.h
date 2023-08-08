//
//  PBTestListCell.h
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBContentModel.h"

@interface PBTestListCell : UITableViewCell

@property (nonatomic, strong) PBContentModel *contentModel;
@property (nonatomic, weak) UIImageView *oneImageView;

@property (nonatomic, weak) YYLabel *lab;

+ (id)testListCellWithTableView:(UITableView *)tableView;

@end
