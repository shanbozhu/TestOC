//
//  PBPhotoBrowserView.h
//  TestBundle
//
//  Created by DaMaiIOS on 16/5/13.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+PBPhBrowserView.h"

@class PBPhotoBrowserView;
@protocol PBPhotoBrowserViewDelegate <NSObject>

// 1.获取缩略图视图(传入缩略图视图主要是为了统一获取缩略图image和size)
- (UIImageView *)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andThumbImageURLWithIndex:(NSInteger)index;

// 2.获取高清图地址
- (NSURL *)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andHDImageURLWithIndex:(NSInteger)index;

@optional
// 收藏和点赞操作
- (void)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andBtn:(UIButton *)btn andIndex:(NSInteger)index;

// 显示收藏和点赞
- (void)photoBrowserView:(PBPhotoBrowserView *)photoBrowserView andCollectBtn:(UIButton *)collectBtn andZanBtn:(UIButton *)zanBtn andIndex:(NSInteger)index;

@end

@interface PBPhotoBrowserView : UIView

@property (nonatomic, weak) UIView *sourceImageFatherView; // 来源视图
@property (nonatomic, assign) NSInteger currentImageIndex; // 当前图片索引
@property (nonatomic, assign) NSInteger imageCount; // 图片数量
@property (nonatomic, assign) BOOL isCarousel; // 区分九宫格和轮播

@property (nonatomic, weak) UIView *sourceImageSlideView; // 临时加载
@property (nonatomic, assign) BOOL isCollect; // 是否显示收藏

@property (nonatomic, strong) NSArray *imgModelIndexArr; // 存储是图片的模型对象所在原数组中的下标

@property (nonatomic, weak) id<PBPhotoBrowserViewDelegate> delegate;

+ (id)photoBrowserView;
- (void)show; // 显示图片浏览器

@end
