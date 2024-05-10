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
        self.frame = CGRectMake(0, ([UIApplication sharedApplication].statusBarFrame.size.height + 44), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - ([UIApplication sharedApplication].statusBarFrame.size.height + 44));
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
        
        //
        UILabel *view = [[UILabel alloc]init];
        view.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150);
        view.backgroundColor = [UIColor whiteColor];
        view.text = @"tableHeaderView";
        view.textAlignment = NSTextAlignmentCenter;
        _tableView.tableHeaderView = view;
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
    return self.frame.size.height - kSectionViewHeight - kSectionViewHeight;
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
    if (section == 0) {
        UIView *view = [[UIView alloc]init];
        view.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kSectionViewHeight);
        view.backgroundColor = [UIColor redColor];
        return view;
    }
    // 选择header
    return self.sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return kSectionViewHeight;
    }
    return kSectionViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (PBLinkageSectionView *)sectionView {
    if (!_sectionView) {
        _sectionView = [PBLinkageSectionView linkageSectionViewWithTableView:self.tableView];
        _sectionView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kSectionViewHeight);
        
        _sectionView.segmentControl.frame = _sectionView.bounds;
        __weak typeof(self) weakSelf = self;
        [_sectionView.segmentControl setIndexChangeBlock:^(NSUInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.containerCell.scrollView setContentOffset:CGPointMake(index * [UIScreen mainScreen].bounds.size.width, 0) animated:YES];
        }];
    }
    return _sectionView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat bottomCellOffset = [self.tableView rectForSection:1].origin.y;
        if (scrollView.contentOffset.y >= (bottomCellOffset - kSectionViewHeight)) {
            scrollView.contentOffset = CGPointMake(0, bottomCellOffset - kSectionViewHeight);
            if (self.canScroll) {
                self.canScroll = NO;
                self.containerCell.objectCanScroll = YES;
            }
        } else {
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
    NSUInteger page = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    [self.sectionView.segmentControl setSelectedSegmentIndex:page animated:YES];
    self.tableView.scrollEnabled = YES;
}

@end
