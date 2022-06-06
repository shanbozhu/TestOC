//
//  PBCellHeightFiveCell.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFiveCell.h"
#import <YYText.h>
#import <Masonry.h>

@interface PBCellHeightFiveCell ()

@property (nonatomic, weak) YYLabel *lab;

@end

@implementation PBCellHeightFiveCell

// required
- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, CGRectGetMaxY(self.lab.frame) + 20);
}

+ (instancetype)testListFiveCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBCellHeightFiveCell"];
    PBCellHeightFiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBCellHeightFiveCell"];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        YYLabel *lab = [[YYLabel alloc] init];
        self.lab = lab;
        [self.contentView addSubview:lab];
        lab.numberOfLines = 0;
        lab.font = [UIFont systemFontOfSize:15];
    }
    return self;
}

- (void)setTestListData:(PBCellHeightZeroData *)testListData {
    _testListData = testListData;
    
    [self fillTestListCell];
}

- (void)fillTestListCell {
    self.lab.frame = CGRectMake(20, 20, [UIScreen mainScreen].bounds.size.width - 40, 10000);
    self.lab.text = self.testListData.content;
    [self.lab sizeToFit];
}

- (void)dealloc {
    NSLog(@"PBCellHeightFiveCell对象被释放了");
}

@end
