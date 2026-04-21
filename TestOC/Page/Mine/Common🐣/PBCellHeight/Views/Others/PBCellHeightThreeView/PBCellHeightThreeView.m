//
//  PBCellHeightThreeView.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightThreeView.h"
#import "PBCellHeightThreeCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface PBCellHeightThreeView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightThreeView

+ (id)testListThreeView {
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
    return self.testList.data.count;
}

// required
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightZeroData *testListData = self.testList.data[indexPath.row];
    
    if (!testListData.cellHeight) {
        [tableView registerClass:[PBCellHeightThreeCell class] forCellReuseIdentifier:@"PBCellHeightThreeCell"];
        testListData.cellHeight = [tableView fd_heightForCellWithIdentifier:@"PBCellHeightThreeCell" configuration:^(id cell) {
            PBCellHeightThreeCell *tmpCell = cell;
            tmpCell.testListData = self.testList.data[indexPath.row];
        }];
    }
    return testListData.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightThreeCell *cell = [PBCellHeightThreeCell testListThreeCellWithTableView:tableView];
    cell.testListData = self.testList.data[indexPath.row];
    return cell;
}

@end
