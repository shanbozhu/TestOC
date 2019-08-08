//
//  PBPhotoBrowserPageView.m
//  TestBundle
//
//  Created by DaMaiIOS on 16/5/13.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBPhotoBrowserPageView.h"
#import "UIImageView+WebCache.h"

// 屏幕宽度 屏幕高度
#define kPBSWidth [UIScreen mainScreen].bounds.size.width
#define kPBSHeight [UIScreen mainScreen].bounds.size.height

#define minZoomScale 0.6
#define maxZoomScale 2.0

@interface PBPhotoBrowserPageView ()<UIScrollViewDelegate>

@property (nonatomic, assign) BOOL isFinishLoadImage;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation PBPhotoBrowserPageView

+ (id)photoBrowserPageView {
    return [[self alloc]initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        // scrollView
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        self.scrollView = scrollView;
        [self addSubview:scrollView];
        scrollView.frame = CGRectMake(0, 0, kPBSWidth, kPBSHeight);
        scrollView.delegate = self;
        
        // imageView
        UIImageView *imageView = [[UIImageView alloc]init];
        self.imageView = imageView;
        [scrollView addSubview:imageView];
        // 去除在由缩略图下载完为高清图时的抖动
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        // 双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapClick:)];
        [self addGestureRecognizer:doubleTap];
        doubleTap.numberOfTapsRequired = 2;
        
        // 单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapClick:)];
        [self addGestureRecognizer:singleTap];
        singleTap.numberOfTapsRequired = 1;
        
        // 双击时屏蔽单击
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (void)singleTapClick:(UITapGestureRecognizer *)tap {
    // 移除图片浏览器之前先还原图片的缩放比例
    [self.scrollView setZoomScale:1.0 animated:YES];
    
    // 移除图片浏览器
    [self.delegate photoBrowserPageView:self andTapGestureRecognizer:tap];
}

- (void)doubleTapClick:(UITapGestureRecognizer *)tap {
    // 在线状态下图片下载完毕后才能进行放大或缩小;离线状态下无论何时都可以放大或缩小
    if (self.isFinishLoadImage == YES) {
        CGPoint touchPoint = [tap locationInView:self];
        if (self.scrollView.zoomScale <= 1.0) {
            CGFloat scaleX = touchPoint.x + self.scrollView.contentOffset.x;
            CGFloat scaleY = touchPoint.y + self.scrollView.contentOffset.y;
            [self.scrollView zoomToRect:CGRectMake(scaleX, scaleY, 10, 10) animated:YES];
        } else {
            [self.scrollView setZoomScale:1.0 animated:YES];
        }
    }
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImageView *)placeholder {
    // 在高清图还未下载完毕时用缩略图高度占位
    CGRect twoTargetRect;
    CGFloat twoPlaceholderH;
    
    // 缩略图高度
    if (placeholder.pbTag == 1) {
        // 微信
        if (placeholder.image != nil) {
            twoPlaceholderH = placeholder.frame.size.height;
        } else {
            twoPlaceholderH = 0;
        }
        
        if (twoPlaceholderH <= kPBSHeight) {
            twoTargetRect = CGRectMake((kPBSWidth-placeholder.frame.size.width)/2, (kPBSHeight-twoPlaceholderH)/2, placeholder.frame.size.width, twoPlaceholderH);
        } else {
            twoTargetRect = CGRectMake(0, 0, kPBSWidth, twoPlaceholderH);
        }
        
        self.imageView.frame = twoTargetRect;
    } else {
        // 新浪
        if (placeholder.image != nil) {
            twoPlaceholderH = kPBSWidth/placeholder.image.size.width*placeholder.image.size.height;
        } else {
            twoPlaceholderH = 0;
        }
        
        if (twoPlaceholderH <= kPBSHeight) {
            twoTargetRect = CGRectMake(0, (kPBSHeight-twoPlaceholderH)/2, kPBSWidth, twoPlaceholderH);
        } else {
            twoTargetRect = CGRectMake(0, 0, kPBSWidth, twoPlaceholderH);
        }
        
        self.imageView.frame = twoTargetRect;
    }
    
    // 在无法正确获取实际大小时进行模糊进度显示
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]init];
    self.activityIndicatorView = activityIndicatorView;
    [self addSubview:activityIndicatorView];
    activityIndicatorView.center = CGPointMake(kPBSWidth/2, kPBSHeight/2);
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [activityIndicatorView startAnimating];
    
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:url placeholderImage:placeholder.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        CGRect oneTargetRect;
        CGFloat onePlaceholderH;
        
        // 高清图高度
        if (image != nil) {
            onePlaceholderH = kPBSWidth/image.size.width*image.size.height;
        } else {
            onePlaceholderH = 0;
        }
        
        if (onePlaceholderH <= kPBSHeight) {
            oneTargetRect = CGRectMake(0, (kPBSHeight-onePlaceholderH)/2, kPBSWidth, onePlaceholderH);
        } else {
            oneTargetRect = CGRectMake(0, 0, kPBSWidth, onePlaceholderH);
        }
        
        if (!CGRectEqualToRect(twoTargetRect, oneTargetRect)) {
            if (placeholder.image == nil && image != nil) { // 之前是placeholder
                weakSelf.imageView.frame = oneTargetRect;
            }
            
            if (placeholder.image != nil && image != nil) { // 之前是placeholder
                weakSelf.imageView.frame = twoTargetRect;
                
                CGFloat showImageAnimationDuration = 0.3;
                [UIView animateWithDuration:showImageAnimationDuration animations:^{
                    weakSelf.imageView.frame = oneTargetRect;
                }];
            }
        }
        
        // 长图片可以向下滚动查看
        weakSelf.scrollView.contentSize = weakSelf.imageView.frame.size;
        weakSelf.scrollView.contentOffset = CGPointZero; // 一开始刚下载完,偏移量默认为(0,0)
        
        CGFloat maxScale = kPBSHeight/oneTargetRect.size.height;
        if (kPBSWidth/oneTargetRect.size.width > maxScale) {
            maxScale = kPBSWidth/oneTargetRect.size.width;
        } else {
            maxScale = maxScale;
        }
        if (maxScale > maxZoomScale) {
            maxScale = maxScale;
        } else {
            maxScale = maxZoomScale;
        }
        
        weakSelf.scrollView.minimumZoomScale = minZoomScale;
        weakSelf.scrollView.maximumZoomScale = maxScale;
        weakSelf.scrollView.zoomScale = 1.0;
        
        // 下载成功,移除等待视图
        if (error == nil) {
            [weakSelf.activityIndicatorView stopAnimating];
            [weakSelf.activityIndicatorView removeFromSuperview];
        }
        
        weakSelf.isFinishLoadImage = YES;
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (void)dealloc {
    NSLog(@"PBPhotoBrowserPageView对象被释放了");
}

@end
