//
//  PBLinkagePosterCell.m
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkagePosterCell.h"

@implementation PBLinkagePosterCell

+ (instancetype)linkagePosterCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBLinkagePosterCell"];
    PBLinkagePosterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBLinkagePosterCell"];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.text = @"海报cell";
    }
    return self;
}

@end
