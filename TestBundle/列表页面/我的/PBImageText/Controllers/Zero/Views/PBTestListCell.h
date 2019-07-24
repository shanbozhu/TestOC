//
//  PBTestListCell.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBContentModel.h"

// 是否使用YYLabel
#define USEYYLabel

@interface PBTestListCell : UITableViewCell

@property (nonatomic, strong) PBContentModel *contentModel;
@property (nonatomic, weak) UIImageView *oneImageView;

#ifdef USEYYLabel
@property (nonatomic, weak) YYLabel *lab;
#else
@property (nonatomic, weak) YYTextView *textView;
#endif

+ (id)testListCellWithTableView:(UITableView *)tableView;

@end
