//
//  PBCellHeightFourCell.m
//  TestBundle
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFourCell.h"
#import <YYText.h>
#import <Masonry.h>

@interface PBCellHeightFourCell ()

@property(nonatomic, weak)YYLabel *lab;

@end

@implementation PBCellHeightFourCell

+(id)testListFourCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBCellHeightFourCell"];
    PBCellHeightFourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBCellHeightFourCell"];
    return cell;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //
        YYLabel *lab = [[YYLabel alloc]init];
        self.lab = lab;
        [self.contentView addSubview:lab];
        
        
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.top.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.bottom.mas_equalTo(-20); //不能缺少
        }];
        
        //
        [self layoutIfNeeded];
    }
    return self;
}

-(void)setTestListData:(PBCellHeightZeroData *)testListData {
    _testListData = testListData;
    
    [self fillTestListCell];
}
-(void)fillTestListCell {
    
    //
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width -40, 10000)];
    container.maximumNumberOfRows = 0;
    container.truncationType = YYTextTruncationTypeEnd;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:self.testListData.content];
    [attStr yy_setFont:[UIFont systemFontOfSize:15] range:attStr.yy_rangeOfAll];
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:attStr];
    self.lab.textLayout = layout;
    
    //
    [self.lab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(layout.textBoundingSize.height);
    }];
    
}

-(void)dealloc {
    NSLog(@"PBCellHeightFourCell对象被释放了");
}

@end
