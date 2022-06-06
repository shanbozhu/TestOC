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

@interface PBCellHeightFiveView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightFiveView

+ (id)testListFiveView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        [self addSubview:tableView];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 0; // required
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
    [tableView registerClass:[PBCellHeightFiveCell class] forCellReuseIdentifier:@"PBCellHeightFiveCell"];
    return [tableView fd_heightForCellWithIdentifier:@"PBCellHeightFiveCell" configuration:^(id cell) {
        PBCellHeightFiveCell *tmpCell = cell;
        tmpCell.testListData = self.testList.data[indexPath.row];
        
        tmpCell.fd_enforceFrameLayout = YES;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightFiveCell *cell = [PBCellHeightFiveCell testListFiveCellWithTableView:tableView];
    cell.testListData = self.testList.data[indexPath.row];
    return cell;
}

@end
