//
//  PBChannelHeaderView.m
//  PBTest
//
//  Created by DaMaiIOS on 17/5/25.
//  Copyright © 2017年 朱善波. All rights reserved.
//

#import "PBChannelHeaderView.h"

@interface PBChannelHeaderView ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *showView;
@property (nonatomic, strong) NSMutableArray *btnArr;

@end

@implementation PBChannelHeaderView

- (NSMutableArray *)btnArr {
    if (_btnArr == nil) {
        _btnArr = [NSMutableArray array];
    }
    return _btnArr;
}

+ (id)channelView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        // scrollView
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        self.scrollView = scrollView;
        [self addSubview:scrollView];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

- (void)setChannelArr:(NSArray *)channelArr {
    _channelArr = channelArr;
    [self fillChannelView];
}

- (void)fillChannelView {
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    self.btnArr = nil;
    
    // showView
    UIView *showView = [[UIView alloc] init];
    self.showView = showView;
    [self.scrollView addSubview:self.showView];
    showView.backgroundColor = [UIColor redColor];
    
    for (int i = 0; i < self.channelArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.scrollView addSubview:btn];
        [self.btnArr addObject:btn];
        //btn.layer.borderWidth = 0.5;
        //btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        
        if (i == 0) {
            btn.titleLabel.font = [UIFont systemFontOfSize:20];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else {
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [btn setTitle:self.channelArr[i] forState:UIControlStateNormal];
        
        UILabel *lab = [[UILabel alloc] init];
        //[btn addSubview:lab];
        lab.textColor = [UIColor redColor];
        lab.frame = CGRectMake(20, 0, 100, 0);
        lab.text = self.channelArr[i];
        [lab sizeToFit];
        CGRect rect = lab.frame;
        rect.origin.y = (self.frame.size.height - lab.frame.size.height) / 2;
        lab.frame = rect;
        
        if (i == 0) {
            btn.frame = CGRectMake(0, 0, lab.frame.size.width + 40, self.frame.size.height);
            self.showView.frame = CGRectMake(btn.frame.origin.x, btn.frame.size.height - 2, btn.frame.size.width, 2);
        } else {
            btn.frame = CGRectMake(CGRectGetMaxX([self.btnArr[i - 1] frame]), 0, lab.frame.size.width + 40, self.frame.size.height);
        }
    }
    self.scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX([[self.btnArr lastObject] frame]), 0);
}

- (void)btnClick:(UIButton *)btn {
    [self.delegate channelView:self andIndex:btn.tag];
    [self moveWithIndex:btn.tag];
}

- (void)setContentOffsetWithOffset:(CGPoint)offset {
    // 偏移一半就切换状态
    NSInteger index = (offset.x + [UIScreen mainScreen].bounds.size.width / 2.0) / [UIScreen mainScreen].bounds.size.width;
    [self moveWithIndex:index];
}

- (void)moveWithIndex:(NSInteger)index {
    for (int i = 0; i < self.btnArr.count; i++) {
        UIButton *btn = [self.btnArr objectAtIndex:i];
        if (i == index) {
            btn.titleLabel.font = [UIFont systemFontOfSize:20];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else {
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    UIButton *selectBtn = [self.btnArr objectAtIndex:index];
    
    // 标签居中
    float offsetx = selectBtn.frame.origin.x - ([UIScreen mainScreen].bounds.size.width - selectBtn.frame.size.width) / 2.0;
    
    // 向左移动,最小偏移量
    if (offsetx < 0) {
        offsetx = 0;
    }
    
    // 向右移动,最大偏移量
    if (offsetx + self.scrollView.frame.size.width > self.scrollView.contentSize.width) {
        offsetx = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.scrollView setContentOffset:CGPointMake(offsetx, 0) animated:NO];
        self.showView.frame = CGRectMake(selectBtn.frame.origin.x, selectBtn.frame.size.height - 2, selectBtn.frame.size.width, 2);
    }];
}

@end
