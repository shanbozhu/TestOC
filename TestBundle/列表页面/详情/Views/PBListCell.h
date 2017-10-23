//
//  PBListCell.h
//  PBHome
//
//  Created by DaMaiIOS on 17/9/16.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBList.h"

@interface PBListCell : UITableViewCell

@property(nonatomic, strong)PBList *list;

+(id)listCellWithTableView:(UITableView *)tableView;

@end
