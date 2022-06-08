//
//  PBCellHeightFiveCell.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFiveCell.h"
#import <Masonry.h>

@interface PBCellHeightFiveCell ()


@end

@implementation PBCellHeightFiveCell

+ (instancetype)testListFiveCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBCellHeightFiveCell"];
    PBCellHeightFiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBCellHeightFiveCell"];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //
        YYLabel *lab = [[YYLabel alloc] init];
        self.lab = lab;
        [self.contentView addSubview:lab];
        lab.numberOfLines = 0;
        lab.font = [UIFont systemFontOfSize:labFont];
        lab.layer.borderColor = [UIColor redColor].CGColor;
        lab.layer.borderWidth = 1.1;
        
        //
        UIImageView *imageView = [[UIImageView alloc] init];
        self.oneImageView = imageView;
        [self.contentView addSubview:imageView];
        imageView.layer.borderColor = [UIColor redColor].CGColor;
        imageView.layer.borderWidth = 1.1;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"PBCellHeightFiveCell对象被释放了");
}

@end
