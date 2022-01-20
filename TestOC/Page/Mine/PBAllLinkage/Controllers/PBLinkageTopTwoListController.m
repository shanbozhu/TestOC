//
//  PBLinkageTopTwoListController.m
//  TestOC
//
//  Created by shanbo on 2022/1/19.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageTopTwoListController.h"
#import "YNPageTableView.h"

@interface PBLinkageTopTwoListController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PBLinkageTopTwoListController

- (BOOL)pb_navigationBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO; // 取消自动调节ScrollView内边距
    
    // self.tableView
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第二页————这是第 %@ 行", @(indexPath.row)];
    return cell;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; // 取消自动调节ScrollView内边距
        }
        if (@available(iOS 15, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

@end
