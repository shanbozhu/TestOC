//
//  PBPhotoBrowserView.m
//  陪伴Ta
//
//  Created by DaMaiIOS on 16/5/13.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBPhotoBrowserView.h"
#import "PBPhotoBrowserPageView.h"
#import "UIImageView+WebCache.h"

//屏幕宽度 屏幕高度
#define kPBSWidth [UIScreen mainScreen].bounds.size.width
#define kPBSHeight [UIScreen mainScreen].bounds.size.height

//图片间距
#define imageMargin 10


@interface PBPhotoBrowserView()<UIScrollViewDelegate, PBPhotoBrowserPageViewDelegate>

@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, weak)UILabel *indexLab;
@property(nonatomic, weak)UIButton *saveBtn;
@property(nonatomic, weak)UIButton *collectBtn;
@property(nonatomic, weak)UIButton *zanBtn;

@property(nonatomic, assign)BOOL isShowImageAnimation;
@property(nonatomic, assign)NSInteger lastIndex; //最后的索引

@property(nonatomic, weak)UIActivityIndicatorView *activityIndicatorView;

@end

@implementation PBPhotoBrowserView

//加载视图
+(id)photoBrowserView {
    return [[self alloc]initWithFrame:CGRectZero];
}
-(id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        //scrollView
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        self.scrollView = scrollView;
        [self addSubview:scrollView];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        
        //序标
        UILabel *indexLab = [[UILabel alloc]init];
        self.indexLab = indexLab;
        [self addSubview:indexLab];
        indexLab.font = [UIFont boldSystemFontOfSize:20];
        indexLab.textColor = [UIColor whiteColor];
        indexLab.textAlignment = NSTextAlignmentCenter;
        indexLab.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.3];
        
        //收藏
        UIButton *collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.collectBtn = collectBtn;
        [self addSubview:collectBtn];
        collectBtn.frame = CGRectMake(20, kPBSHeight-45, 45, 30);
        [collectBtn setImage:[UIImage imageNamed:@"wei_shoucang"] forState:UIControlStateNormal];
        [collectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        collectBtn.layer.cornerRadius = 2;
        collectBtn.layer.masksToBounds = YES;
        [collectBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        collectBtn.tag = 0;
        
        
        //点赞
        UIButton *zanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.zanBtn = zanBtn;
        [self addSubview:zanBtn];
        zanBtn.frame = CGRectMake((kPBSWidth-45)/2, kPBSHeight-45, 45, 30);
        [zanBtn setImage:[UIImage imageNamed:@"zanT"] forState:UIControlStateNormal];
        [zanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        zanBtn.layer.cornerRadius = 2;
        zanBtn.layer.masksToBounds = YES;
        [zanBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        zanBtn.tag = 1;
        
        
        
        //保存
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.saveBtn = saveBtn;
        [self addSubview:saveBtn];
        saveBtn.frame = CGRectMake(kPBSWidth-65, kPBSHeight-45, 45, 30);
        [saveBtn setImage:[UIImage imageNamed:@"xiazai"] forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        saveBtn.layer.cornerRadius = 2;
        saveBtn.layer.masksToBounds = YES;
        [saveBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        saveBtn.tag = 2;
        
        
        //设置自定义视图背景色
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}
-(void)show {
    
    //添加到window
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.frame = CGRectMake(0, 0, kPBSWidth, kPBSHeight);
    
    
    //隐藏状态栏
    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelStatusBar;
    
    if (self.isShowImageAnimation == NO) {
        [self showImageAnimation];
    }
}


-(void)btnClick:(UIButton *)btn {
    
    
    if (btn.tag == 2) {
    
        
        //保存
        NSInteger index = (self.scrollView.contentOffset.x)/self.scrollView.frame.size.width;
        PBPhotoBrowserPageView *photoBrowserPageView = self.scrollView.subviews[index];
        UIImageWriteToSavedPhotosAlbum(photoBrowserPageView.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]init];
        self.activityIndicatorView = activityIndicatorView;
        [[UIApplication sharedApplication].keyWindow addSubview:activityIndicatorView];
        activityIndicatorView.center = self.center;
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [activityIndicatorView startAnimating];
    
    } else {
        
        [self.delegate photoBrowserView:self andBtn:btn andIndex:self.lastIndex];
        
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    //保存成功
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    
    
    //保存成功提示
    UILabel *hintLab = [[UILabel alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:hintLab];
    hintLab.frame = CGRectMake(0, 0, 150, 40);
    hintLab.center = self.center;
    hintLab.font = [UIFont boldSystemFontOfSize:20];
    hintLab.textColor = [UIColor whiteColor];
    hintLab.textAlignment = NSTextAlignmentCenter;
    hintLab.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    hintLab.layer.cornerRadius = 5;
    hintLab.layer.masksToBounds = YES;
    if (error) {
        hintLab.text = @"保存失败";
    } else {
        hintLab.text = @"保存成功";
    }
    
    [hintLab performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

//填充视图
-(void)fillPhotoBrowserViewWithThumbImage:(UIImageView *)thumbImage {
    
    //首先移除自定义视图上的所有子视图
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    //显示收藏和点赞
    [self showCollectAndZan:self.currentImageIndex];
    
    
    for (int i = 0; i < self.imageCount; i++) {
        PBPhotoBrowserPageView *photoBrowserPageView = [[PBPhotoBrowserPageView alloc] init];
        [self.scrollView addSubview:photoBrowserPageView];
        photoBrowserPageView.frame = CGRectMake((kPBSWidth+imageMargin*2)*i, 0, kPBSWidth+imageMargin*2, kPBSHeight);
        
        photoBrowserPageView.delegate = self;
        if (self.imgModelIndexArr == nil) {
            photoBrowserPageView.imageView.tag = i;
        } else {
            photoBrowserPageView.imageView.tag = [self.imgModelIndexArr[i] integerValue];
        }
    }
    
    //显示当前点击的图片的高清图,下面语句一定要先于设置scrollView的contentOffset执行
    [self showHDImageForImageViewWithIndex:self.currentImageIndex andThumbImage:thumbImage];
    
    
    //设置scrollView的frame
    self.scrollView.frame = CGRectMake(0, 0, kPBSWidth+imageMargin*2, kPBSHeight);
    self.scrollView.contentSize = CGSizeMake((kPBSWidth+imageMargin*2)*self.scrollView.subviews.count, kPBSHeight);
    
    //scrollView偏移滚动到当前点击的图片位置
    self.scrollView.contentOffset = CGPointMake(self.currentImageIndex*self.scrollView.frame.size.width, 0);
    
    
    //序标
    if (self.imageCount > 1) {
        self.indexLab.frame = CGRectMake((kPBSWidth-80)/2, 15, 80, 30);
        self.indexLab.layer.cornerRadius = 15;
        self.indexLab.layer.masksToBounds = YES;
        self.indexLab.text = [NSString stringWithFormat:@"%ld/%ld", self.lastIndex+1, self.imageCount];
        self.indexLab.adjustsFontSizeToFitWidth = YES;
    }
    
}



-(void)photoBrowserPageView:(PBPhotoBrowserPageView *)photoBrowserPageView andTapGestureRecognizer:(UITapGestureRecognizer *)tap {
    
    NSInteger index = photoBrowserPageView.imageView.tag;
    
    //NSLog(@"index = %ld", index);
    
    
    //临时加载
    if (self.sourceImageSlideView != nil) {
        
        if ([self.sourceImageSlideView isKindOfClass:[UITableView class]]) {
            
            UITableViewCell *cell = [(UITableView *)self.sourceImageSlideView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            self.sourceImageFatherView = cell.contentView;
            
        } else {
            
            
            UICollectionViewCell *cell = [(UICollectionView *)self.sourceImageSlideView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            self.sourceImageFatherView = cell.contentView;
        }
    }
    
    
    
    UIImageView *sourceImageView;
    if (self.sourceImageSlideView == nil) {

        if (self.isCarousel == YES) {
            sourceImageView = self.sourceImageFatherView.subviews[self.currentImageIndex];
        } else {
            if (index < self.sourceImageFatherView.subviews.count) {
                sourceImageView = self.sourceImageFatherView.subviews[index];
            }
        }
        
    } else {
        sourceImageView = self.sourceImageFatherView.subviews[0];
    }

    
    //将源视图sourceImageFatherView上的sourceImageView的坐标转换到相对于self的坐标
    CGRect rect = [self.sourceImageFatherView convertRect:sourceImageView.frame toView:self];
    
    if (self.isCarousel == YES) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PBParallaxHeaderView" object:nil userInfo:@{@"index":[NSNumber numberWithInteger:index]}];
    }
    
    //临时动画图片视图
    UIImageView *tmpImageView = [[UIImageView alloc]init];
    [self addSubview:tmpImageView];
    tmpImageView.frame = photoBrowserPageView.imageView.frame;
    tmpImageView.image = photoBrowserPageView.imageView.image;
    //去除退回到缩略图时的抖动
    tmpImageView.contentMode = UIViewContentModeScaleAspectFill;
    tmpImageView.clipsToBounds = YES;

    //执行动画之前必须要做
    self.scrollView.hidden = YES;
    self.indexLab.hidden = YES;
    self.saveBtn.hidden = YES;
    self.collectBtn.hidden = YES;
    self.zanBtn.hidden = YES;
    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
    
    CGFloat hideImageAnimationDuration = 0.3;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:hideImageAnimationDuration animations:^{
        
        
        if (self.sourceImageFatherView != nil) {
            
            //临时加载
            if (rect.size.height != 0) {
                tmpImageView.frame = rect;
            } else {
                tmpImageView.frame = CGRectZero;
                tmpImageView.center = weakSelf.center;
            }
            
            //背景渐渐变淡
            self.backgroundColor = [UIColor clearColor];
            
        } else {
            [self fadeOut];
        }
        
    } completion:^(BOOL finished) {
        
        if (self.sourceImageFatherView != nil) {
            [tmpImageView removeFromSuperview];
            [weakSelf removeFromSuperview];
        }
        
        
    }];
}


-(void)showCollectAndZan:(NSInteger)index {
    
    //游客登录不显示收藏和点赞
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"visitorLogin"] == YES) {
        [self.collectBtn removeFromSuperview];
        [self.zanBtn removeFromSuperview];
        return;
    }
    

    //九宫格没有收藏和点赞
    if (self.isCollect == NO) {
        
        [self.collectBtn removeFromSuperview];
        [self.zanBtn removeFromSuperview];
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(photoBrowserView:andCollectBtn:andZanBtn:andIndex:)]) {
            [self.delegate photoBrowserView:self andCollectBtn:self.collectBtn andZanBtn:self.zanBtn andIndex:index];
        }
        
    }
}

//缩略图动画
-(void)showImageAnimation {
    
    UIImageView *sourceImageView;
    if (self.sourceImageSlideView == nil) {
        //九宫格或轮播
        sourceImageView = self.sourceImageFatherView.subviews[self.currentImageIndex];
    } else {
        //tableview或collectionview
        sourceImageView = self.sourceImageFatherView.subviews[0];
    }
    
    //将源视图sourceImageFatherView上的sourceImageView的坐标转换到相对于self的坐标
    CGRect rect = [self.sourceImageFatherView convertRect:sourceImageView.frame toView:self];
    
    //临时动画图片视图
    UIImageView *tmpImageView = [[UIImageView alloc]init];
    [self addSubview:tmpImageView];
    tmpImageView.frame = rect;
    UIImageView *tmpImageViewTwo = [self thumbImageWithIndex:self.currentImageIndex];
    tmpImageView.image = tmpImageViewTwo.image;
    //去除显示缩略图动画时的抖动
    tmpImageView.contentMode = UIViewContentModeScaleAspectFill;
    tmpImageView.clipsToBounds = YES;
    
    CGRect targetRect;
    CGFloat placeholderH;
    
    CGFloat showImageAnimationDuration;
    
    if (tmpImageViewTwo.pbTag == 1) {
        
        //微信
        if (tmpImageView.image == nil) {
            placeholderH = 0;
        } else {
            placeholderH = tmpImageView.frame.size.height;
        }
        
        if (placeholderH <= kPBSHeight) {
            targetRect = CGRectMake((kPBSWidth-tmpImageView.frame.size.width)/2, (kPBSHeight-placeholderH)/2, tmpImageView.frame.size.width, placeholderH);
        } else {
            targetRect = CGRectMake(0, 0, kPBSWidth, placeholderH);
        }
        
        tmpImageView.pbTag = tmpImageViewTwo.pbTag;
        
        showImageAnimationDuration = 0.2;
        
    } else {
        
        
        
        //新浪
        if (tmpImageView.image == nil) {
            placeholderH = 0;
        } else {
            placeholderH = kPBSWidth/tmpImageView.image.size.width*tmpImageView.image.size.height;
        }
        
        if (placeholderH <= kPBSHeight) {
            targetRect = CGRectMake(0, (kPBSHeight-placeholderH)/2, kPBSWidth, placeholderH);
        } else {
            targetRect = CGRectMake(0, 0, kPBSWidth, placeholderH);
        }
        
        
        tmpImageView.pbTag = tmpImageViewTwo.pbTag;
        
        
        showImageAnimationDuration = 0.3;
    }
    
    

    
    
    
    
    //执行动画之前必须要做
    self.scrollView.hidden = YES;
    self.indexLab.hidden = YES;
    self.saveBtn.hidden = YES;
    self.collectBtn.hidden = YES;
    self.zanBtn.hidden = YES;
    
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:showImageAnimationDuration animations:^{
        
        if (self.sourceImageFatherView != nil) {
            tmpImageView.frame = targetRect;
        } else {
            [self fadeIn];
        }
        
    } completion:^(BOOL finished) {
        
        weakSelf.isShowImageAnimation = YES;
        weakSelf.scrollView.hidden = NO;
        weakSelf.indexLab.hidden = NO;
        weakSelf.saveBtn.hidden = NO;
        weakSelf.collectBtn.hidden = NO;
        weakSelf.zanBtn.hidden = NO;
        
        
        //填充视图
        [weakSelf fillPhotoBrowserViewWithThumbImage:tmpImageView];

        
        //imageView会被释放,但是imageView上的image不会被释放
        [tmpImageView removeFromSuperview];
    }];
    
    
    //最后的索引
    self.lastIndex = self.currentImageIndex;
}

//渐出效果
-(void)fadeOut {
    [self setAlpha:1];
    [UIView transitionWithView:self duration:2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


//渐入效果
-(void)fadeIn {
    [self setAlpha:0];
    [UIView transitionWithView:self duration:2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self setAlpha:1];
    } completion:nil];
}



//显示高清图
-(void)showHDImageForImageViewWithIndex:(NSInteger)index andThumbImage:(UIImageView *)thumbImage {
    
    
    PBPhotoBrowserPageView *photoBrowserPageView = self.scrollView.subviews[index];
    
    if (photoBrowserPageView.isLoadingImage == NO) {
        
        if (thumbImage != nil) {
            //第一次显示高清图,容易出现高清图由于异步下载,慢一步显示的问题
            [photoBrowserPageView setImageWithURL:[self hdImageURLWithIndex:index] placeholderImage:thumbImage];
        } else {
            [photoBrowserPageView setImageWithURL:[self hdImageURLWithIndex:index] placeholderImage:[self thumbImageWithIndex:index]];
        }
        
        photoBrowserPageView.isLoadingImage = YES;
    }
    
}

//获取高清图地址
-(NSURL *)hdImageURLWithIndex:(NSInteger)index {
   return [self.delegate photoBrowserView:self andHDImageURLWithIndex:index];
}
//获取缩略图视图
-(UIImageView *)thumbImageWithIndex:(NSInteger)index {

    
    UIImageView *tmpImageView = [[UIImageView alloc]init];
    [tmpImageView sd_setImageWithURL:[self hdImageURLWithIndex:index]];
    if (tmpImageView.image == nil) {
        
        tmpImageView = [self.delegate photoBrowserView:self andThumbImageURLWithIndex:index];
        tmpImageView.pbTag = 1; //缩略(微信) (此处修改的是真正的原视图上的缩略图对象)
    } else {
        
        
        tmpImageView.pbTag = 2; //高清(新浪)
        
    }
    
    //打开下面语句则是新浪模式,注释则为微信模式
    tmpImageView.pbTag = 2;
    
    NSLog(@"tmpImageView.image = %@", tmpImageView.image);
    return tmpImageView;
}



//scrollView代理方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger index = (scrollView.contentOffset.x)/scrollView.frame.size.width;
    NSInteger left = index-1;
    NSInteger right = index+1;
    
    
    if (left < 0) {
        left = 0;
    }
    if (right > scrollView.subviews.count-1) {
        right = scrollView.subviews.count-1;
    }
    //预加载三张
    for (long i = left; i <= right; i++) {
        
        [self showHDImageForImageViewWithIndex:i andThumbImage:nil];
    }
    //只加载当前张
    //[self showHDImageForImageViewWithIndex:index andThumbImage:nil];
    
    
    //设置序标
    NSInteger indexForLab = (scrollView.contentOffset.x+scrollView.frame.size.width*0.5)/scrollView.frame.size.width;
    if (indexForLab < 0) {
        indexForLab = 0;
    }
    if (indexForLab > scrollView.subviews.count-1) {
        indexForLab = scrollView.subviews.count-1;
    }
    self.indexLab.text = [NSString stringWithFormat:@"%ld/%ld", indexForLab+1, self.imageCount];
    
    
    //显示收藏和点赞
    [self showCollectAndZan:indexForLab];
    
    //最后的索引
    self.lastIndex = indexForLab;
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSLog(@"我在调用");
    
    NSInteger index = (scrollView.contentOffset.x)/scrollView.frame.size.width;
    NSInteger left = index-1;
    NSInteger right = index+1;
    
    
    if (left < 0) {
        left = 0;
    }
    if (right > scrollView.subviews.count-1) {
        right = scrollView.subviews.count-1;
    }
    
    for (long i = left; i <= right; i++) {
        
        if (i != index) {
            
            PBPhotoBrowserPageView *photoBrowserPageView = scrollView.subviews[i];
            [photoBrowserPageView.scrollView setZoomScale:1.0];
        }
        
    }
}

-(void)dealloc {
    NSLog(@"PBPhotoBrowserView对象被释放了");
}



@end
