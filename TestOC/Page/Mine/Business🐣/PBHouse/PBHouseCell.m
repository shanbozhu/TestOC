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

@property (nonatomic, weak) YYLabel *lab;

@end

@implementation PBHouseCell

// required
- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, CGRectGetMaxY(self.lab.frame) + 10);
}

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
        lab.font = [UIFont systemFontOfSize:16];
        lab.numberOfLines = 0;
    }
    return self;
}

- (void)setShowData:(PBHouseShowData *)showData {
    _showData = showData;
    [self fillHouseCell];
}

- (void)fillHouseCell {
    self.lab.frame = CGRectMake(10, 10, APPLICATION_FRAME_WIDTH - 20, 50 - 20);
    self.lab.text = [NSString stringWithFormat:@"%@%@", self.showData.title, self.showData.content];
    [self.lab sizeToFit];
    if ([self.showData.color isEqualToString:@"green"]) {
        self.lab.textColor = [UIColor redColor];
    } else if ([self.showData.color isEqualToString:@"gray"]) {
        self.lab.textColor = [UIColor blueColor];
    } else {
        self.lab.textColor = [UIColor blackColor];
    }
}

@end
