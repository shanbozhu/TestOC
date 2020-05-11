//
//  PBSeatSelectionView.m
//  TestOC
//
//  Created by DaMaiIOS on 17/8/8.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//


#import "PBSeatSelectionView.h"
#import "PBSeatsView.h"
#import "PBRowIndexView.h"
#import "PBHallLogoView.h"
#import "PBAppLogoView.h"
#import "PBCenterLineView.h"
#import "PBTestEspressos.h"

@interface PBSeatSelectionView ()<UIScrollViewDelegate, PBSeatsViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) PBSeatsView *seatsView;
@property (nonatomic, weak) PBRowIndexView *rowIndexView;
@property (nonatomic, weak) PBHallLogoView *hallLogoView;
@property (nonatomic, weak) PBAppLogoView *appLogoView;
@property (nonatomic, weak) PBCenterLineView *centerLineView;

@end

#define kPBSeatsViewRowMargin 55
#define kPBSeatBtnMinW_H 10
#define kPBSeatsViewColMargin 60
#define kPBSeatBtnStartAnimationW_H 25
#define kPBSeatBtnMaxW_H 40
#define kPBHallLogoW 200
#define kPBAppLogoW 100
#define kPBCenterLineW 1
#define kPBRowIndexW 20

@implementation PBSeatSelectionView

+ (id)seatSelectionViewWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:245.0/255.0
                                               green:245.0/255.0
                                                blue:245.0/255.0 alpha:1];
        
        // scrollView
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        self.scrollView = scrollView;
        [self addSubview:scrollView];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        //scrollView.backgroundColor = [UIColor redColor];

        // seatsView
        PBSeatsView *seatsView = [PBSeatsView seatsView];
        self.seatsView = seatsView;
        [self.scrollView addSubview:seatsView];
        seatsView.delegate = self;
        //seatsView.layer.borderWidth = 1;
        //seatsView.layer.borderColor = [UIColor yellowColor].CGColor;
        
        // rowIndexView
        PBRowIndexView *rowIndexView = [PBRowIndexView rowIndexView];
        self.rowIndexView = rowIndexView;
        [self.scrollView addSubview:rowIndexView];
        
        // hallLogoView
        PBHallLogoView *hallLogoView = [PBHallLogoView hallLogoView];
        self.hallLogoView = hallLogoView;
        if (kPBDaMaiMode == NO) {
            [self.scrollView addSubview:hallLogoView];
        } else {
            [self addSubview:hallLogoView];
        }
        
        // appLogoView
        PBAppLogoView *appLogoView = [PBAppLogoView appLogoView];
        self.appLogoView = appLogoView;
        if (kPBDaMaiMode == NO) {
            [self.scrollView addSubview:appLogoView];
        }
        
        // centerLineView
        PBCenterLineView *centerLineView = [PBCenterLineView centerLineView];
        self.centerLineView = centerLineView;
        if (kPBDaMaiMode == NO) {
            [self.scrollView addSubview:centerLineView];
        }
    }
    return self;
}

- (void)setTestEspressos:(PBTestEspressos *)testEspressos {
    _testEspressos = testEspressos;
    
    [self fillSeatSelectionView];
}

- (void)fillSeatSelectionView {
    // seatsView
    NSInteger colCount = self.testEspressos.maxColCount;
    
    if (colCount % 2 == 1) {
        colCount = colCount + 1; // 奇数列数加1,手动添加一列成为偶数列,防止中线压住座位
    }
    
    NSLog(@"colCount = %ld", colCount);
    
    CGFloat seatBtnWidth = kPBSeatBtnMinW_H;
    CGFloat seatsViewWidth = colCount * kPBSeatBtnMinW_H;
    CGFloat seatBtnHeight = seatBtnWidth;
    CGFloat seatsViewHeight = self.testEspressos.seats.count * seatBtnHeight;
    
    self.seatsView.seatBtnWidth = seatBtnWidth;
    self.seatsView.seatBtnHeight = seatBtnHeight;
    
    self.seatsView.frame = CGRectMake(0, 0, seatsViewWidth, seatsViewHeight);
    self.seatsView.testEspressos = self.testEspressos;
    
    // scrollView
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = kPBSeatBtnMaxW_H / self.seatsView.seatBtnWidth;
    self.scrollView.contentInset = UIEdgeInsetsMake(kPBSeatsViewColMargin, kPBSeatsViewRowMargin, kPBSeatsViewColMargin, kPBSeatsViewRowMargin);
    self.scrollView.contentOffset = CGPointMake((self.seatsView.frame.size.width - self.scrollView.frame.size.width) / 2.0, 0);
    
    // rowIndexView
    self.rowIndexView.frame = CGRectMake(self.scrollView.contentOffset.x + 10, -10, kPBRowIndexW, self.seatsView.frame.size.height + 2.0 * 10);
    self.rowIndexView.testEspressos = self.testEspressos;
    self.rowIndexView.layer.cornerRadius = self.rowIndexView.frame.size.width * 0.5;
    self.rowIndexView.layer.masksToBounds = YES;
    
    // hallLogoView
    if (kPBDaMaiMode == NO) {
        self.hallLogoView.frame = CGRectMake((self.seatsView.frame.size.width - kPBHallLogoW) / 2.0, self.scrollView.contentOffset.y, kPBHallLogoW, 20);
    } else {
        self.hallLogoView.frame = CGRectMake((self.scrollView.frame.size.width - kPBHallLogoW) / 2.0, 0, kPBHallLogoW, 20);
    }
    self.hallLogoView.testEspressos = self.testEspressos;
    
    // appLogoView
    self.appLogoView.frame = CGRectMake((self.seatsView.frame.size.width - kPBAppLogoW) / 2.0, self.scrollView.frame.size.height - 40 - kPBSeatsViewColMargin, kPBAppLogoW, 40);
    
    // centerLineView
    self.centerLineView.frame = CGRectMake((self.seatsView.frame.size.width - kPBCenterLineW) / 2.0, self.scrollView.contentOffset.y + 50, kPBCenterLineW, self.testEspressos.seats.count * kPBSeatBtnStartAnimationW_H + 2.0 * 10);
    
    // startAnimation
    [self startAnimation];
}

- (void)startAnimation {
    if (kPBDaMaiMode == NO) {
        [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect zoomRect = [self zoomRectInView:self.scrollView andScale:kPBSeatBtnStartAnimationW_H / self.seatsView.seatBtnWidth andCenter:CGPointMake(self.seatsView.frame.size.width / 2.0, 0)];
            [self.scrollView zoomToRect:zoomRect animated:NO];
        } completion:^(BOOL finished) {
            
            
        }];
    } else {
        {
            CGRect zoomRect = [self zoomRectInView:self.scrollView andScale:kPBSeatBtnStartAnimationW_H / self.seatsView.seatBtnWidth andCenter:CGPointMake(self.seatsView.frame.size.width / 2.0, 0)];
            [self.scrollView zoomToRect:zoomRect animated:NO];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.seatsView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    {
        // rowIndexView
        CGRect rect = self.rowIndexView.frame;
        rect.origin.x = scrollView.contentOffset.x + 10;
        self.rowIndexView.frame = rect;
    }
    
    {
        if (kPBDaMaiMode == NO) {
            // hallLogoView
            CGRect rect = self.hallLogoView.frame;
            rect.origin.y = scrollView.contentOffset.y;
            self.hallLogoView.frame = rect;
        }
    }
    
    {
        // appLogoView
        CGRect rect = self.appLogoView.frame;
        if (scrollView.contentOffset.y <= scrollView.contentSize.height - scrollView.frame.size.height + kPBSeatsViewColMargin + 15) {
            rect.origin.y = CGRectGetMaxY(self.seatsView.frame) + 20 + 15;
        } else {
            rect.origin.y = scrollView.contentOffset.y + scrollView.frame.size.height - self.appLogoView.frame.size.height;
        }
        self.appLogoView.frame = rect;
    }
    
    {
        // centerLineView
        CGRect rect = self.centerLineView.frame;
        if (scrollView.contentOffset.y < - kPBSeatsViewColMargin) {
            rect.origin.y = self.seatsView.frame.origin.y - kPBSeatsViewColMargin + 50;
            rect.size.height = CGRectGetMaxY(self.seatsView.frame) + 2.0 * 10;
        } else {
            rect.origin.y = scrollView.contentOffset.y + 50;
            rect.size.height = CGRectGetMaxY(self.seatsView.frame) - scrollView.contentOffset.y - 2.0 * 50 + kPBSeatsViewColMargin;
        }
        self.centerLineView.frame = rect;
    }
    
    if (scrollView.zoomScale >= scrollView.maximumZoomScale) {
        self.rowIndexView.hidden = NO;
    } else {
        self.rowIndexView.hidden = YES;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    {
        // rowIndexView
        CGRect rect = self.rowIndexView.frame;
        rect.size.height = self.seatsView.frame.size.height + 2.0 * 10;
        self.rowIndexView.frame = rect;
    }
    
    {
        if (kPBDaMaiMode == NO) {
            // hallLogoView
            CGRect rect = self.hallLogoView.frame;
            rect.origin.x = (self.seatsView.frame.size.width - kPBHallLogoW) / 2.0;
            self.hallLogoView.frame = rect;
        }
    }
    
    {
        // appLogoView
        CGRect rect = self.appLogoView.frame;
        rect.origin.x = (self.seatsView.frame.size.width - kPBAppLogoW) / 2.0;
        self.appLogoView.frame = rect;
    }
    
    {
        // centerLineView
        CGRect rect = self.centerLineView.frame;
        rect.origin.x = (self.seatsView.frame.size.width - 1) / 2.0;
        self.centerLineView.frame = rect;
    }
}

- (void)seatsView:(PBSeatsView *)seatsView andSeatBtn:(PBSeatButton *)seatBtn {
    // 只在第一次点击座位到达最大缩放高度后,其他次点击座位不在执行缩放,否则每次都会移动座位居中显示
    if (self.scrollView.maximumZoomScale == self.scrollView.zoomScale) {
        return;
    }
    
    CGRect zoomRect = [self zoomRectInView:self.scrollView andScale:self.scrollView.maximumZoomScale andCenter:CGPointMake(seatBtn.center.x, seatBtn.center.y)];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectInView:(UIView *)view andScale:(CGFloat)scale andCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.width = view.bounds.size.width / scale;
    zoomRect.size.height = view.bounds.size.height / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

@end
