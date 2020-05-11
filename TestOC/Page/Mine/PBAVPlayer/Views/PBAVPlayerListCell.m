//
//  PBAVPlayerListCell.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAVPlayerListCell.h"
#import "UIImageView+WebCache.h"
#import <YYText/YYText.h>

@interface PBAVPlayerListCell ()

@property (nonatomic, weak) YYLabel *lab;
@property (nonatomic, weak) UIImageView *oneImageView;
@property (nonatomic, weak) UIView *separatorView;

@end

@implementation PBAVPlayerListCell

+ (id)testListCellWithTableView:(UITableView *)tableView andReuseIdentifier:(NSString *)reuseIdentifier {
    PBAVPlayerListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // oneImageView
        UIImageView *oneImageView = [[UIImageView alloc]init];
        self.oneImageView = oneImageView;
        [self.contentView addSubview:oneImageView];
        oneImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
        oneImageView.contentMode = UIViewContentModeScaleAspectFill;
        oneImageView.clipsToBounds = YES;
        
        // oneBtn
        UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:oneBtn];
        oneBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-60)/2, (300-60)/2, 60, 60);
        [oneBtn addTarget:self action:@selector(oneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [oneBtn setBackgroundImage:[UIImage imageNamed:@"PBPlayBtn"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setTestEspressos:(PBAVPlayerList *)testEspressos {
    _testEspressos = testEspressos;
    
    [self.oneImageView sd_setImageWithURL:[NSURL URLWithString:self.testEspressos.pictureUrl]];
}

- (void)oneBtnClick:(UIButton *)btn {
    self.delegate = (id)[self viewController];
    [self.delegate testListCell:self andTestEspressos:self.testEspressos];
}

// 获取view所在的controller方法
- (UIViewController *)viewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)dealloc {
    NSLog(@"TestListCell对象被释放了");
}

@end
