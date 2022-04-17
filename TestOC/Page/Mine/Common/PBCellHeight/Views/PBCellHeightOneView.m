//
//  PBCellHeightOneView.m
//  TestOC
//
//  Created by DaMaiIOS on 2018/6/15.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightOneView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "PBCellHeightOneCell.h"

@interface PBCellHeightOneView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightOneView

+ (id)testListOneView {
    return [[self alloc]initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        [self addSubview:tableView];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 0;
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
    [tableView registerClass:[PBCellHeightOneCell class] forCellReuseIdentifier:@"PBCellHeightOneCell"];
    return [tableView fd_heightForCellWithIdentifier:@"PBCellHeightOneCell" configuration:^(id cell) {
        PBCellHeightOneCell *tmpCell = cell;
        tmpCell.testListData = self.testList.data[indexPath.row];
        
        tmpCell.fd_enforceFrameLayout = YES;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBCellHeightOneCell *cell = [PBCellHeightOneCell testListOneCellWithTableView:tableView];
    cell.testListData = self.testList.data[indexPath.row];
    return cell;
}

@end
