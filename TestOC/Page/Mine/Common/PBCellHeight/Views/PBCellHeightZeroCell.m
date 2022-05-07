//
//  PBCellHeightZeroCell.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightZeroCell.h"
#import <YYText.h>

@interface PBCellHeightZeroCell ()

@property (nonatomic, weak) YYLabel *lab;

@end

@implementation PBCellHeightZeroCell

+ (instancetype)testListCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBCellHeightZeroCell"];
    PBCellHeightZeroCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBCellHeightZeroCell"];
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
    
    // required
    CGRect rect = self.frame;
    rect.size.height = CGRectGetMaxY(self.lab.frame) + 20;
    self.frame = rect;
}

- (void)dealloc {
    NSLog(@"PBCellHeightZeroCell对象被释放了");
}

@end
