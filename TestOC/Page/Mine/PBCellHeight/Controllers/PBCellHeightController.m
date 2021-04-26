//
//  PBCellHeightController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBCellHeightController.h"
#import "PBCellHeightZeroController.h"
#import "PBCellHeightOneController.h"
#import "PBCellHeightTwoController.h"
#import "PBCellHeightThreeController.h"
#import "PBCellHeightFourController.h"

/**
 1.根据宽度内容设置高度,内容包括文本、字体、行间距
 2.根据子视图高度设置父视图高度
 3.紧贴上一控件
 */

/**
 调用layoutIfNeeded方法,会立即触发调用layoutSubviews方法
 调用setNeedsLayout方法,会在下一个刷新周期触发调用layoutSubviews方法
 
 调用setNeedsDisplay方法,会在下一个刷新周期触发调用drawRect:方法
 */

@interface PBCellHeightController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 0;
    tableView.tableFooterView = [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"frame布局,通用手动算高";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"frame布局,手动算高";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"frame布局,自动算高";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"autolayout布局,手动算高";
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"autolayout布局,自动算高";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        PBCellHeightZeroController *testListController = [[PBCellHeightZeroController alloc]init];
        
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row == 1) {
        PBCellHeightOneController *testListOneController = [[PBCellHeightOneController alloc]init];
        
        [self.navigationController pushViewController:testListOneController animated:YES];
        testListOneController.view.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row == 2) {
        PBCellHeightTwoController *testListTwoController = [[PBCellHeightTwoController alloc]init];
        
        [self.navigationController pushViewController:testListTwoController animated:YES];
        testListTwoController.view.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row == 3) {
        PBCellHeightThreeController *testListThreeController = [[PBCellHeightThreeController alloc]init];
        
        [self.navigationController pushViewController:testListThreeController animated:YES];
        testListThreeController.view.backgroundColor = [UIColor whiteColor];
    } else {
        PBCellHeightFourController *testListFourController = [[PBCellHeightFourController alloc]init];
        
        [self.navigationController pushViewController:testListFourController animated:YES];
        testListFourController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
