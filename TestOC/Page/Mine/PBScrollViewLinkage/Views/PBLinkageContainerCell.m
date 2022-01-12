//
//  PBLinkageContainerCell.m
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageContainerCell.h"

@implementation PBLinkageContainerCell

+ (instancetype)linkageContainerCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBLinkageContainerCell"];
    PBLinkageContainerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBLinkageContainerCell"];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

@end
