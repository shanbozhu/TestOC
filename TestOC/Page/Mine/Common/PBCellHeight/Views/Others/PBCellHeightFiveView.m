//
//  PBCellHeightFiveView.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFiveView.h"
#import "PBCellHeightFiveCell.h"
#import "PBCellHeightFiveCellVM.h"
#import "PBRefresh.h"

@interface PBCellHeightFiveView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightFiveView

+ (id)testListFiveView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // 刷新
        __weak typeof(self) weakSelf = self;
        self.tableView.mj_header = [PBRefresh refreshHeaderWithTarget:self refreshingBlock:^(PBRefresh *refresh) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.delegate cellHeightFiveView:strongSelf sinceId:0 status:0];
        }];
        self.tableView.mj_footer = [PBRefresh refreshFooterWithTarget:self refreshingBlock:^(PBRefresh *refresh) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSInteger sinceId = 1000; // 提供个假值
            [strongSelf.delegate cellHeightFiveView:strongSelf sinceId:sinceId status:1];
        }];
    }
    return self;
}

- (void)setTestList:(PBCellHeightZero *)testList {
    _testList = testList;
    [self.tableView reloadData];
    
    // 刷新
    [self.tableView.mj_header endRefreshing];
    if (self.testList.dataAddIsNull) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.tableView.mj_footer endRefreshing];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testList.data.count;
}

// required
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightFiveCellVM *fiveCellVM = self.testList.data[indexPath.row];
    return fiveCellVM.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightFiveCell *cell = [PBCellHeightFiveCell testListFiveCellWithTableView:tableView];
    cell.fiveCellVM = self.testList.data[indexPath.row];
    return cell;
}

@end
