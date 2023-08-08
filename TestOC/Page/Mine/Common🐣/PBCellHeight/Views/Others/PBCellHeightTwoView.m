//
//  PBCellHeightTwoView.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightTwoView.h"
#import "PBCellHeightTwoCell.h"

@interface PBCellHeightTwoView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightTwoView

+ (id)testListTwoView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tableView.estimatedRowHeight = 100; // required
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testList.data.count;
}

// required
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightZeroData *testListData = self.testList.data[indexPath.row];
    
    if (!testListData.cellHeight) {
        return UITableViewAutomaticDimension;
    }
    return testListData.cellHeight;
}

// required
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightZeroData *testListData = self.testList.data[indexPath.row];
    testListData.cellHeight = cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightTwoCell *cell = [PBCellHeightTwoCell testListTwoCellWithTableView:tableView];
    cell.testListData = self.testList.data[indexPath.row];
    return cell;
}

@end
