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

@interface PBCellHeightFiveView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightFiveView

+ (id)testListFiveView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

// required
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightFiveCellVM *fiveCellVM = self.dataArr[indexPath.row];
    return fiveCellVM.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightFiveCell *cell = [PBCellHeightFiveCell testListFiveCellWithTableView:tableView];
    cell.fiveCellVM = self.dataArr[indexPath.row];
    return cell;
}

@end
