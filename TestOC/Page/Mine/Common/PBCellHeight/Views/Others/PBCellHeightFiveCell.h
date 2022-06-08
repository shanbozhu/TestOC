//
//  PBCellHeightFiveCell.h
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYText.h>

#define labFont 15

@interface PBCellHeightFiveCell : UITableViewCell

@property (nonatomic, weak) YYLabel *lab;
@property (nonatomic, weak) UIImageView *oneImageView;

+ (id)testListFiveCellWithTableView:(UITableView *)tableView;

@end
