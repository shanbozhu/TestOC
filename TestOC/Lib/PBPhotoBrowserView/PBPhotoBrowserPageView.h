//
//  PBPhotoBrowserPageView.h
//  TestOC
//
//  Created by DaMaiIOS on 16/5/13.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+PBPhBrowserView.h"

@class PBPhotoBrowserPageView;
@protocol PBPhotoBrowserPageViewDelegate <NSObject>

- (void)photoBrowserPageView:(PBPhotoBrowserPageView *)photoBrowserPageView andTapGestureRecognizer:(UITapGestureRecognizer *)tap;

@end

@interface PBPhotoBrowserPageView : UIView

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL isLoadingImage; // 是否正在加载图片

@property (nonatomic, weak) id<PBPhotoBrowserPageViewDelegate> delegate;

+ (id)photoBrowserPageView;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImageView *)placeholder;

@end
