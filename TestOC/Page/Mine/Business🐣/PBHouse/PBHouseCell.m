//
//  PBHouseCell.m
//  TestOC
//
//  Created by zhushanbo on 2025/3/28.
//  Copyright © 2025 DaMaiIOS. All rights reserved.
//

#import "PBHouseCell.h"
#import <YYText/YYText.h>

@interface PBHouseCell ()

@property (nonatomic, strong) YYLabel *lab;

@end

@implementation PBHouseCell

+ (instancetype)houseCellWithTableView:(UITableView *)tableView; {
    PBHouseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBHouseCell"];
    if (!cell) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PBHouseCell"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // lab
        YYLabel *lab = [[YYLabel alloc] initWithFrame:CGRectZero];
        self.lab = lab;
        [self.contentView addSubview:lab];
        lab.frame = CGRectMake(10, 10, APPLICATION_FRAME_WIDTH - 20, 50 - 20);
        lab.font = [UIFont systemFontOfSize:20];
        lab.numberOfLines = 0;
    }
    return self;
}

- (void)setShowData:(PBHouseShowData *)showData {
    _showData = showData;
    [self fillHouseCell];
}

- (void)fillHouseCell {
    self.lab.text = [NSString stringWithFormat:@"%@：%@", self.showData.title, self.showData.content];
}


@end
