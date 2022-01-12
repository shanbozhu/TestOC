//
//  PBLinkageDescCell.m
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageDescCell.h"

@implementation PBLinkageDescCell

+ (instancetype)linkageDescCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBLinkageDescCell"];
    PBLinkageDescCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBLinkageDescCell"];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.text = @"简介cell";
    }
    return self;
}


@end
