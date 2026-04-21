//
//  PBCellHeightBaseView.m
//  TestOC
//
//  Created by shanbo on 2022/6/10.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightBaseView.h"

@interface PBCellHeightBaseView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - APPLICATION_NAVIGATIONBAR_HEIGHT) style:UITableViewStylePlain];
        self.tableView = tableView;
        [self addSubview:tableView];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 0; // required
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

@end
