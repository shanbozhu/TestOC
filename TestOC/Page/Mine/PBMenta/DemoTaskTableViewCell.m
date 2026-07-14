//
//  DemoTaskTableViewCell.m
//  Menta-iOS_Example
//
//  Created by vlion on 2026/3/3.
//  Copyright © 2026 JiaDingYi. All rights reserved.
//

#import "DemoTaskTableViewCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface DemoTaskTableViewCell ()

@property (nonatomic, strong) UIView *adView;

@end


@implementation DemoTaskTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)updateWithAdObject:(MUVidEarnAdObject *)object {
    if (self.adView) {
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
    
    self.adView = [self createAdViewWithAdObject:object];
    [object registerClickableViews:@[self.adView] closeableViews:nil];
}

- (UIView *)createAdViewWithAdObject:(MUVidEarnAdObject *)object {
    UIView *adView = object.nativeAdView;
    adView.backgroundColor = UIColor.lightGrayColor;
    adView.frame = self.bounds;
    [self addSubview:adView];
    
    CGFloat marginHorizontal = 10;
    CGFloat marginVertical = 5;
    
    // 图标
    UIImageView *iconImageView = UIImageView.new;
    iconImageView.layer.cornerRadius = 10;
    iconImageView.layer.masksToBounds = YES;
    [iconImageView sd_setImageWithURL:[NSURL URLWithString:object.dataObject.materialList.firstObject.materialUrl]];
    [adView addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(adView).offset(marginVertical);
        make.bottom.equalTo(adView).offset(-marginVertical);
        make.width.equalTo(iconImageView.mas_height);
    }];
    
    // 标题
    UILabel *titleLabel = UILabel.new;
    titleLabel.text = object.dataObject.title;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = UIColor.blackColor;
    [adView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImageView);
        make.left.equalTo(iconImageView.mas_right).offset(marginHorizontal);
        make.right.equalTo(adView).offset(-marginHorizontal);
        make.height.mas_equalTo(20);
    }];
    
    // 描述
    UILabel *descLabel = UILabel.new;
    descLabel.text = object.dataObject.desc;
    descLabel.font = [UIFont systemFontOfSize:12];
    descLabel.textColor = UIColor.whiteColor;
    [adView addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(marginVertical);
        make.left.equalTo(iconImageView.mas_right).offset(marginHorizontal);
        make.right.equalTo(adView).offset(-marginHorizontal);
        make.height.mas_equalTo(20);
    }];
    
    // 描述2
    UILabel *subDescLabel = UILabel.new;
    subDescLabel.text = object.task.taskDesc;
    subDescLabel.font = [UIFont systemFontOfSize:12];
    subDescLabel.textColor = UIColor.whiteColor;
    [adView addSubview:subDescLabel];
    [subDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(descLabel.mas_bottom).offset(marginVertical);
        make.left.equalTo(iconImageView.mas_right).offset(marginHorizontal);
        make.right.equalTo(adView).offset(-marginHorizontal);
        make.height.mas_equalTo(20);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:object.task.btnTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [adView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subDescLabel.mas_bottom).offset(marginVertical);
        make.right.equalTo(adView).offset(-marginHorizontal);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(80);
    }];
    btn.layer.borderColor = [UIColor grayColor].CGColor;
    btn.layer.borderWidth = 1.112;
    
    // 描述3
    UILabel *messageLabel = UILabel.new;
    messageLabel.numberOfLines = 0;
    messageLabel.text = object.task.taskMessage;
    messageLabel.font = [UIFont systemFontOfSize:12];
    messageLabel.textColor = UIColor.blueColor;
    [adView addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subDescLabel.mas_bottom).offset(marginVertical);
        make.left.equalTo(iconImageView.mas_right).offset(marginHorizontal);
        make.right.equalTo(btn.mas_left).offset(-marginHorizontal);
        make.height.mas_equalTo(40);
    }];
    return adView;
}

@end
