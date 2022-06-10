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
@property (nonatomic, weak) UIImageView *oneImageView;

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

- (void)setFiveCellVM:(PBCellHeightFiveCellVM *)fiveCellVM {
    _fiveCellVM = fiveCellVM;
    [self fillTestListCell];
}

- (void)fillTestListCell {
    //
    self.lab.frame = self.fiveCellVM.labRect;
    self.lab.text = self.fiveCellVM.testListData.content;
    
    //
    self.oneImageView.frame = self.fiveCellVM.imageViewRect;
}

- (void)dealloc {
    NSLog(@"PBCellHeightFiveCell对象被释放了");
}

@end
