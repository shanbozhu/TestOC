//
//  PBCellHeightFiveView.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/16.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightFiveView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "PBCellHeightFiveCell.h"
#import "PBCellHeightFiveCellVM.h"

@interface PBCellHeightFiveView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation PBCellHeightFiveView

+ (id)testListFiveView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        self.tableView = tableView;
        [self addSubview:tableView];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 0; // required
    }
    return self;
}

- (void)setTestListArr:(NSMutableArray *)testListArr {
    _testListArr = testListArr;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testListArr.count;
}

// required
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightFiveCellVM *fiveCellVM = self.testListArr[indexPath.row];
    return fiveCellVM.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightFiveCell *cell = [PBCellHeightFiveCell testListFiveCellWithTableView:tableView];
    PBCellHeightFiveCellVM *fiveCellVM = self.testListArr[indexPath.row];
    [fiveCellVM configureCell:cell];
    return cell;
}

@end
