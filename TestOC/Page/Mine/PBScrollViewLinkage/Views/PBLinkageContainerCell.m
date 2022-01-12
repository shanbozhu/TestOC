//
//  PBLinkageContainerCell.m
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageContainerCell.h"
#import "PBLinkageOneListController.h"
#import "PBLinkageTwoListController.h"
#import "PBLinkageThreeListController.h"

@interface PBLinkageContainerCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) PBLinkageOneListController *oneVC;
@property (nonatomic, strong) PBLinkageTwoListController *twoVC;
@property (nonatomic, strong) PBLinkageThreeListController *threeVC;

@end

@implementation PBLinkageContainerCell

+ (instancetype)linkageContainerCellWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:@"PBLinkageContainerCell"];
    PBLinkageContainerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PBLinkageContainerCell"];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.scrollView];
        [self configScrollView];
    }
    return self;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, APPLICATION_FRAME_WIDTH, kHeight)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, _scrollView.frame.size.height);
    }
    return _scrollView;
}

- (void)configScrollView {
    self.oneVC = [[PBLinkageOneListController alloc] init];
    self.twoVC = [[PBLinkageTwoListController alloc] init];
    self.threeVC = [[PBLinkageThreeListController alloc] init];
    
    [self.scrollView addSubview:self.oneVC.view];
    [self.scrollView addSubview:self.twoVC.view];
    [self.scrollView addSubview:self.threeVC.view];
    
    self.oneVC.view.frame = CGRectMake(0, 0, APPLICATION_FRAME_WIDTH, kHeight);
    self.twoVC.view.frame = CGRectMake(APPLICATION_FRAME_WIDTH, 0, APPLICATION_FRAME_WIDTH, kHeight);
    self.threeVC.view.frame = CGRectMake(APPLICATION_FRAME_WIDTH * 2, 0, APPLICATION_FRAME_WIDTH, kHeight);
}

- (void)setObjectCanScroll:(BOOL)objectCanScroll {
    _objectCanScroll = objectCanScroll;
    
    self.oneVC.vcCanScroll = objectCanScroll;
    self.twoVC.vcCanScroll = objectCanScroll;
    self.threeVC.vcCanScroll = objectCanScroll;
    
    if (!objectCanScroll) {
        [self.oneVC.tableView setContentOffset:CGPointZero animated:NO];
        [self.twoVC.tableView setContentOffset:CGPointZero animated:NO];
        [self.threeVC.tableView setContentOffset:CGPointZero animated:NO];
    }
}

// 滑动的时候,外层的tableView不可动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(linkageContainerCellScrollViewDidScroll:)]) {
            [self.delegate linkageContainerCellScrollViewDidScroll:scrollView];
        }
    }
}

// [拖动]滑动结束的时候,外层的tableView可动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(linkageContainerCellScrollViewDidEndDecelerating:)]) {
            [self.delegate linkageContainerCellScrollViewDidEndDecelerating:scrollView];
        }
    }
}

// [点击tab]滑动结束的时候,外层的tableView可动
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(linkageContainerCellScrollViewDidEndDecelerating:)]) {
            [self.delegate linkageContainerCellScrollViewDidEndDecelerating:scrollView];
        }
    }
}

@end
