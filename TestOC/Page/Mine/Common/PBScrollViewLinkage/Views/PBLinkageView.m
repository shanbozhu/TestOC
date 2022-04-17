//
//  PBLinkageView.m
//  TestOC
//
//  Created by shanbo on 2022/1/12.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageView.h"
#import "PBLinkagePosterCell.h"
#import "PBLinkageDescCell.h"
#import "PBLinkageContainerCell.h"
#import "PBLinkageSectionView.h"

@interface PBLinkageView () <UITableViewDelegate, UITableViewDataSource, PBLinkageContainerCellDelegate>

@property (nonatomic, strong) PBLinkageTableView *tableView;
@property (nonatomic, strong) PBLinkageSectionView *sectionView;

@property (nonatomic, assign) BOOL canScroll;

@property (nonatomic, strong) PBLinkageContainerCell *containerCell;

@end

@implementation PBLinkageView

+ (instancetype)linkageView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - APPLICATION_NAVIGATIONBAR_HEIGHT);
        
        // self.tableView
        [self addSubview:self.tableView];
        
        self.canScroll = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollStatus) name:@"leaveTop" object:nil];
    }
    return self;
}

- (void)changeScrollStatus {
    self.canScroll = YES;
    self.containerCell.objectCanScroll = NO;
}

- (PBLinkageTableView *)tableView {
    if (!_tableView) {
        _tableView = [[PBLinkageTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; // 取消自动调节ScrollView内边距
        }
        if (@available(iOS 15, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 200;
        }
        return 100;
    }
    return self.frame.size.height - kSectionViewHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // 海报cell
            PBLinkagePosterCell *cell = [PBLinkagePosterCell linkagePosterCellWithTableView:tableView];
            return cell;
        }
        // 简介cell
        PBLinkageDescCell *cell = [PBLinkageDescCell linkageDescCellWithTableView:tableView];
        return cell;
    }
    // 滑动cell
    PBLinkageContainerCell *cell = [PBLinkageContainerCell linkageContainerCellWithTableView:tableView];
    self.containerCell = cell;
    cell.delegate = self;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 选择header
    return self.sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    }
    return kSectionViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (PBLinkageSectionView *)sectionView {
    if (!_sectionView) {
        _sectionView = [PBLinkageSectionView linkageSectionViewWithTableView:self.tableView];
        _sectionView.frame = CGRectMake(0, 0, APPLICATION_FRAME_WIDTH, kSectionViewHeight);
        
        _sectionView.segmentControl.frame = _sectionView.bounds;
        __weak typeof(self) weakSelf = self;
        [_sectionView.segmentControl setIndexChangeBlock:^(NSUInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.containerCell.scrollView setContentOffset:CGPointMake(index * APPLICATION_FRAME_WIDTH, 0) animated:YES];
        }];
    }
    return _sectionView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat bottomCellOffset = [self.tableView rectForSection:1].origin.y;
        
        if (scrollView.contentOffset.y >= bottomCellOffset) {
            scrollView.contentOffset = CGPointMake(0, bottomCellOffset);
            if (self.canScroll) {
                self.canScroll = NO;
                self.containerCell.objectCanScroll = YES;
            }
        } else {
            // 内部的ScrollView还没滑动到顶部时,外部的ScrollView不可动
            if (!self.canScroll) {
                scrollView.contentOffset = CGPointMake(0, bottomCellOffset);
            }
        }
    }
}

- (void)linkageContainerCellScrollViewDidScroll:(UIScrollView *)scrollView {
    self.tableView.scrollEnabled = NO;
}

- (void)linkageContainerCellScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger page = scrollView.contentOffset.x / APPLICATION_FRAME_WIDTH;
    [self.sectionView.segmentControl setSelectedSegmentIndex:page animated:YES];
    
    self.tableView.scrollEnabled = YES;
}

@end
