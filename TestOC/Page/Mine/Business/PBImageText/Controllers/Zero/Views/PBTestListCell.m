//
//  PBTestListCell.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestListCell.h"
#import "UIImageView+WebCache.h"
#import <YYText/YYText.h>

@interface PBTestListCell ()

@property (nonatomic, weak) UIView *separatorView;

@end

#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation PBTestListCell

+ (id)testListCellWithTableView:(UITableView *)tableView {
    PBTestListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBTestListCell"];
    if (!cell) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PBTestListCell"];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // lab
        YYLabel *lab = [[YYLabel alloc]init];
        self.lab = lab;
        [self.contentView addSubview:lab];
        lab.numberOfLines = 0;
        
        //lab.layer.borderWidth = 1;
        //lab.layer.borderColor = [UIColor redColor].CGColor;
    }
    return self;
}

- (void)setContentModel:(PBContentModel *)contentModel {
    _contentModel = contentModel;
    
    [self fillTestListCell];
}

- (void)fillTestListCell {
    //NSLog(@"self.contentModel.text = %@, self.contentModel.text.length = %ld", self.contentModel.text, self.contentModel.text.length);
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, MAXFLOAT) text:self.contentModel.text];
    
    // lab
    self.lab.frame = CGRectMake(10, 10, textLayout.textBoundingSize.width, textLayout.textBoundingSize.height);
    self.lab.textLayout = textLayout;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, CGRectGetMaxY(self.lab.frame)==0?0.000001:CGRectGetMaxY(self.lab.frame));
}

- (void)dealloc {
    NSLog(@"PBTestListCell对象被释放了");
}

@end
