//
//  PBCycleCollectionView.m
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCycleCollectionView.h"
#import "PBCycleCell.h"
#import "PBCycleTimerProxy.h"

// 轮播时间间隔
static CGFloat scrollInterval = 3.0f;

@interface PBCycleCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PBCycleTimerProxyDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PBCycleCollectionView

//+ (id)testListView {
//    return [[self alloc] initWithFrame:CGRectZero];
//}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        self.collectionView = collectionView;
        [self addSubview:collectionView];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        collectionView.pagingEnabled = true;
        collectionView.showsHorizontalScrollIndicator = false;
        
        collectionView.layer.borderColor = [UIColor blueColor].CGColor;
        collectionView.layer.borderWidth = 1.1;
        
        //
        CGFloat controlHeight = 35.0f;
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - controlHeight, self.bounds.size.width, controlHeight)];
        self.pageControl = pageControl;
        [self addSubview:self.pageControl];
        self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        
        pageControl.layer.borderColor = [UIColor grayColor].CGColor;
        pageControl.layer.borderWidth = 1.1;
        
        //
        PBCycleTimerProxy *cycleTimerProxy = [[PBCycleTimerProxy alloc] init];
        cycleTimerProxy.delegate = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:scrollInterval target:cycleTimerProxy selector:@selector(showNext) userInfo:nil repeats:true];
        self.timer.fireDate = [NSDate distantFuture];
        self.autoPage = NO;
    }
    return self;
}

- (void)setAutoPage:(BOOL)autoPage {
    _autoPage = autoPage;
    NSDate *fireDate = autoPage ? [NSDate dateWithTimeIntervalSinceNow:scrollInterval] : [NSDate distantFuture];
    self.timer.fireDate = fireDate;
}

- (void)setTestList:(PBCellHeightZero *)testList {
    _testList = testList;
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:testList.data];
    [tmpArr addObject:testList.data.firstObject];
    [tmpArr insertObject:testList.data.lastObject atIndex:0];
    testList.data = tmpArr;
    
    self.pageControl.numberOfPages = testList.data.count - 2;
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width, 0)];
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.testList.data.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCycleCell *cell = [PBCycleCell testListCellWithCollectionView:collectionView indexPath:indexPath];
    cell.index = indexPath.item;
    cell.testListData = self.testList.data[indexPath.item];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self cycleScroll];
    
    // 拖拽动作后间隔3s继续轮播
    if (self.autoPage) {
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:scrollInterval];
    }
}

- (void)cycleScroll {
    NSInteger page = self.collectionView.contentOffset.x / self.collectionView.bounds.size.width;
    if (page == 0) {
        // 滚动到左边
        self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width * (self.testList.data.count - 2), 0);
        self.pageControl.currentPage = self.testList.data.count - 2;
    } else if (page == self.testList.data.count - 1) {
        // 滚动到右边
        self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width, 0);
        self.pageControl.currentPage = 0;
    } else {
        self.pageControl.currentPage = page - 1;
    }
}

- (void)cycleTimerProxy:(PBCycleTimerProxy *)timerProxy {
    // 手指拖拽时如果计时器没有停止,禁止自动轮播
    if (self.collectionView.isDragging) {
        return;
    }
    CGFloat targetX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width;
    [self.collectionView setContentOffset:CGPointMake(targetX, 0) animated:true];
}

// 自动轮播结束
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self cycleScroll];
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"PBCycleCollectionView对象被释放了");
}

@end
