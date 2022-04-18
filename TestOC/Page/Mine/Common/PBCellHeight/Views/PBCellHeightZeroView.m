//
//  PBCellHeightZeroView.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightZeroView.h"
#import "PBCellHeightZeroCell.h"

@interface PBCellHeightZeroView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightZeroView

+ (id)testListView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - APPLICATION_NAVIGATIONBAR_HEIGHT) style:UITableViewStylePlain];
        [self addSubview:tableView];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 0;
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 15, *)) {
            tableView.sectionHeaderTopPadding = 0;
        }
        tableView.tableHeaderView = [UIView new];
        tableView.tableFooterView = [UIView new];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testList.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell removeFromSuperview];
    return CGRectGetHeight(cell.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightZeroCell *cell = [PBCellHeightZeroCell testListCellWithTableView:tableView];
    cell.testListData = self.testList.data[indexPath.row];
    return cell;
}

@end
