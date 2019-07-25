//
//  PBYYTextCell.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/9/28.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBYYText.h"

@class PBYYTextCell;
@protocol PBYYTextCellDelegate <NSObject>

- (void)testListCell:(PBYYTextCell *)testListCell;

@end

@interface PBYYTextCell : UITableViewCell

@property (nonatomic, strong) PBYYText *testList;

@property (nonatomic, assign) id<PBYYTextCellDelegate> delegate;

+ (id)testListCellWithTableView:(UITableView *)tableView;

@end
