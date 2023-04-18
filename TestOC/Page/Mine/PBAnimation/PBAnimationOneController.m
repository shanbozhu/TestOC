//
//  PBAnimationOneController.m
//  TestOC
//
//  Created by shanbo on 2023/4/18.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBAnimationOneController.h"

@interface PBAnimationOneController ()

@property (nonatomic, strong) UIButton *oneOuterBtn;
@property (nonatomic, strong) UIButton *oneMiddleBtn;
@property (nonatomic, strong) UIButton *oneInnerBtn;

@property (nonatomic, strong) UIButton *twoOuterBtn;
@property (nonatomic, strong) UIButton *twoMiddleBtn;

@end

@implementation PBAnimationOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // oneMiddleBtn 移动缩放到 twoMiddleBtn
    
    //
    self.oneOuterBtn.frame = CGRectMake(50, 100, 200, 200);
    self.oneMiddleBtn.frame = CGRectMake(20, 20, self.oneOuterBtn.pb_width - 40, self.oneOuterBtn.pb_height - 40);
    self.oneInnerBtn.frame = CGRectMake(20, 20, self.oneMiddleBtn.pb_width - 40, self.oneMiddleBtn.pb_height - 40);
    
    //
    self.twoOuterBtn.frame = CGRectMake(300, 500, 100, 100);
    self.twoMiddleBtn.frame = CGRectMake(20, 20, self.twoOuterBtn.pb_width - 40, self.twoOuterBtn.pb_height - 40);
}

- (void)oneOuterBtnClick:(UIButton *)btn {
    // 截图
    UIGraphicsBeginImageContextWithOptions(self.oneMiddleBtn.frame.size, NO, [UIScreen mainScreen].scale);
    [self.oneMiddleBtn.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //
    CGRect originRect = [self.oneMiddleBtn.superview convertRect:self.oneMiddleBtn.frame toView:[UIApplication sharedApplication].delegate.window];
    UIImageView *bgImageView = [[UIImageView alloc] init];
    [[UIApplication sharedApplication].delegate.window addSubview:bgImageView];
    bgImageView.frame = originRect;
    bgImageView.image = image;
    
    //
    CGRect rect = [self.twoMiddleBtn.superview convertRect:self.twoMiddleBtn.frame toView:[UIApplication sharedApplication].delegate.window];
    CGFloat x = rect.origin.x + rect.size.width / 2; // 中心点x
    CGFloat y = rect.origin.y + rect.size.height / 2; // 中心点y
    [UIView animateWithDuration:10.0f animations:^{
        bgImageView.frame = rect;
    } completion:^(BOOL finished) {
        [bgImageView removeFromSuperview];
    }];
}

- (UIButton *)oneOuterBtn {
    if (!_oneOuterBtn) {
        _oneOuterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _oneOuterBtn.backgroundColor = [UIColor redColor];
        [self.view addSubview:_oneOuterBtn];
        [_oneOuterBtn addTarget:self action:@selector(oneOuterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _oneMiddleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _oneMiddleBtn.backgroundColor = [UIColor blueColor];
        [_oneOuterBtn addSubview:_oneMiddleBtn];
        _oneMiddleBtn.userInteractionEnabled = NO;
        
        _oneInnerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _oneInnerBtn.backgroundColor = [UIColor yellowColor];
        [_oneMiddleBtn addSubview:_oneInnerBtn];
        _oneInnerBtn.userInteractionEnabled = NO;
    }
    return _oneOuterBtn;
}

- (UIButton *)twoOuterBtn {
    if (!_twoOuterBtn) {
        _twoOuterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _twoOuterBtn.backgroundColor = [UIColor redColor];
        [self.view addSubview:_twoOuterBtn];
        
        _twoMiddleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _twoMiddleBtn.backgroundColor = [UIColor blueColor];
        [_twoOuterBtn addSubview:_twoMiddleBtn];
    }
    return _twoOuterBtn;
}

@end
