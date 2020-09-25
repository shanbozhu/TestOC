//
//  PBTestListOneCell.h
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBContentOneModel.h"

@interface PBTestListOneCell : UITableViewCell

@property (nonatomic, strong) PBContentOneModel *contentOneModel;
@property (nonatomic, weak) UIImageView *oneImageView;

+ (id)testListOneCellWithTableView:(UITableView *)tableView andReuseIdentifier:(NSString *)reuseIdentifier;

@end
