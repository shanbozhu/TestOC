//
//  PBTestListCell.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestListOneCell.h"
#import "UIImageView+WebCache.h"
#import <YYText/YYText.h>

@interface PBTestListOneCell ()

#ifdef USEYYLabel
@property (nonatomic, weak) YYLabel *lab;
#else
@property (nonatomic, weak) YYTextView *textView;
#endif
@property (nonatomic, weak) UIView *separatorView;
#ifndef USEYYLabel
@property (nonatomic, weak) UITableView *tableView;
#endif

@end

#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation PBTestListOneCell

+ (id)testListOneCellWithTableView:(UITableView *)tableView andReuseIdentifier:(NSString *)reuseIdentifier {
    PBTestListOneCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
#ifndef USEYYLabel
    cell.tableView = tableView;
#endif
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if ([reuseIdentifier isEqualToString:@"lab"]) {
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
        
        if ([reuseIdentifier isEqualToString:@"imageView"]) {
            // oneImageView
            UIImageView *oneImageView = [[UIImageView alloc]init];
            self.oneImageView = oneImageView;
            [self.contentView addSubview:oneImageView];
            oneImageView.layer.cornerRadius = 5;
            oneImageView.layer.masksToBounds = YES;
            oneImageView.contentMode = UIViewContentModeScaleAspectFill;
            oneImageView.clipsToBounds = YES;
            oneImageView.backgroundColor = [UIColor lightGrayColor];
            
            //oneImageView.layer.borderWidth = 1;
            //oneImageView.layer.borderColor = [UIColor redColor].CGColor;
        }
    }
    return self;
}

#ifndef USEYYLabel
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    self.tableView.panGestureRecognizer.enabled = self.textView.panGestureRecognizer.enabled;
}
#endif

- (void)setContentOneModel:(PBContentOneModel *)contentOneModel {
    _contentOneModel = contentOneModel;
    
    [self fillTestListCell];
}

- (void)fillTestListCell {
    if ([self.reuseIdentifier isEqualToString:@"lab"]) {
        //NSLog(@"self.contentOneModel.text = %@, self.contentOneModel.text.length = %ld", self.contentOneModel.text, self.contentOneModel.text.length);
#ifdef USEYYLabel
        YYTextLayout *textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, MAXFLOAT) text:self.contentOneModel.text];
        
        // lab
        if (self.contentOneModel.text == nil || [self.contentOneModel.text isEqualToAttributedString:[[NSMutableAttributedString alloc] initWithString:@""]]) {
            self.lab.frame = CGRectMake(10, 0, textLayout.textBoundingSize.width, textLayout.textBoundingSize.height);
        } else {
            self.lab.frame = CGRectMake(10, 10, textLayout.textBoundingSize.width, textLayout.textBoundingSize.height);
        }
        self.lab.textLayout = textLayout;
#else
        // textView
        if (self.contentOneModel.text == nil || [self.contentOneModel.text isEqualToAttributedString:[[NSMutableAttributedString alloc] initWithString:@""]]) {
            self.textView.frame = CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width-20, 0);
        } else {
            self.textView.frame = CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-20, 10000);
            self.textView.attributedText = self.contentOneModel.text;
            [self.textView sizeToFit];
        }
#endif
    }
    
    if ([self.reuseIdentifier isEqualToString:@"imageView"]) {
        // oneImageView
        self.oneImageView.frame = CGRectMake(10, 10, self.contentOneModel.imgWidth, self.contentOneModel.imgHeight);
        [self.oneImageView sd_setImageWithURL:[NSURL URLWithString:self.contentOneModel.src]];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if ([self.reuseIdentifier isEqualToString:@"lab"]) {
#ifdef USEYYLabel
        return CGSizeMake(size.width, CGRectGetMaxY(self.lab.frame)==0?0.000001:CGRectGetMaxY(self.lab.frame));
#else
        return CGSizeMake(size.width, CGRectGetMaxY(self.textView.frame)==0?0.000001:CGRectGetMaxY(self.textView.frame));
#endif
    }
    if ([self.reuseIdentifier isEqualToString:@"imageView"]) {
        return CGSizeMake(size.width, CGRectGetMaxY(self.oneImageView.frame));
    }
    return size;
}

- (void)dealloc {
    NSLog(@"PBTestListOneCell对象被释放了");
}

@end
