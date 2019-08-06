//
//  PBAVPlayerListCell.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBAVPlayerList.h"

@class PBAVPlayerListCell;
@protocol PBAVPlayerListCellDelegate <NSObject>

- (void)testListCell:(PBAVPlayerListCell *)testListCell andTestEspressos:(PBAVPlayerList *)testEspressos;

@end

@interface PBAVPlayerListCell : UITableViewCell

@property (nonatomic, strong) PBAVPlayerList *testEspressos;
@property (nonatomic, weak) id<PBAVPlayerListCellDelegate> delegate;

+ (id)testListCellWithTableView:(UITableView *)tableView andReuseIdentifier:(NSString *)reuseIdentifier;

@end
