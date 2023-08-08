//
//  PBYYTextView.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBYYTextView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "PBYYTextCell.h"

@interface PBYYTextView ()<UITableViewDelegate, UITableViewDataSource, PBYYTextCellDelegate>

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation PBYYTextView

+ (id)testListView {
    return [[self alloc]initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        self.tableView = tableView;
        [self addSubview:tableView];
        tableView.delaysContentTouches = NO; // required
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 0;
    }
    return self;
}

- (void)setTestList:(PBYYText *)testList {
    _testList = testList;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.testList) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBYYTextCell *cell = [PBYYTextCell testListCellWithTableView:tableView];
    cell.testList = self.testList;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[PBYYTextCell class] forCellReuseIdentifier:@"PBYYTextCell"];
    return [tableView fd_heightForCellWithIdentifier:@"PBYYTextCell" configuration:^(id cell) {
        PBYYTextCell *tmpCell = cell;
        tmpCell.testList = self.testList;
        tmpCell.fd_enforceFrameLayout = YES;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"点击了cell");
}

- (void)testListCell:(PBYYTextCell *)testListCell {
    [self.tableView reloadData];
}

@end
