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
#ifndef USEYYLabel
@property (nonatomic, weak) UITableView *tableView;
#endif

@end

#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation PBTestListCell

+ (id)testListCellWithTableView:(UITableView *)tableView {
    PBTestListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBTestListCell"];
    if (cell == nil) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PBTestListCell"];
    }
#ifndef USEYYLabel
    cell.tableView = tableView;
#endif
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
#ifdef USEYYLabel
        // lab
        YYLabel *lab = [[YYLabel alloc]init];
        self.lab = lab;
        [self.contentView addSubview:lab];
        lab.numberOfLines = 0;
        
        //lab.layer.borderWidth = 1;
        //lab.layer.borderColor = [UIColor redColor].CGColor;
#else
        // textView
        YYTextView *textView = [[YYTextView alloc]init];
        self.textView = textView;
        [self.contentView addSubview:textView];
        textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        textView.editable = NO;
        
        //textView.layer.borderWidth = 1;
        //textView.layer.borderColor = [UIColor redColor].CGColor;
        
        // 防止textView的选择复制与父视图的滚动手势冲突
        [self.textView addObserver:self forKeyPath:@"panGestureRecognizer.enabled" options:NSKeyValueObservingOptionNew context:nil];
#endif
    }
    return self;
}

#ifndef USEYYLabel
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    self.tableView.panGestureRecognizer.enabled = self.textView.panGestureRecognizer.enabled;
}
#endif

- (void)setContentModel:(PBContentModel *)contentModel {
    _contentModel = contentModel;
    
    [self fillTestListCell];
}

- (void)fillTestListCell {
    //NSLog(@"self.contentModel.text = %@, self.contentModel.text.length = %ld", self.contentModel.text, self.contentModel.text.length);
#ifdef USEYYLabel
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, MAXFLOAT) text:self.contentModel.text];
    
    // lab
    self.lab.frame = CGRectMake(10, 10, textLayout.textBoundingSize.width, textLayout.textBoundingSize.height);
    self.lab.textLayout = textLayout;
#else
    // textView
    self.textView.frame = CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-20, 100000);
    self.textView.attributedText = self.contentModel.text;
    [self.textView sizeToFit];
#endif
}

- (CGSize)sizeThatFits:(CGSize)size {
#ifdef USEYYLabel
    return CGSizeMake(size.width, CGRectGetMaxY(self.lab.frame)==0?0.000001:CGRectGetMaxY(self.lab.frame));
#else
    return CGSizeMake(size.width, CGRectGetMaxY(self.textView.frame)==0?0.000001:CGRectGetMaxY(self.textView.frame));
#endif
}

- (void)dealloc {
    NSLog(@"PBTestListCell对象被释放了");
}

@end
