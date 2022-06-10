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
#import "PBCellHeightFiveController.h"
#import "PBCellHeightCollectionZeroController.h"
#import "PBCellHeightCollectionOneController.h"
#import "PBCellHeightCollectionTwoController.h"

/**
 1.根据宽度内容设置高度,内容包括文本、字体、行间距
 2.根据子视图高度设置父视图高度
 3.紧贴上一控件
 */

/**
 [self setNeedsLayout];
 [self layoutIfNeeded];
 先调用setNeedsLayout方法,在调用layoutIfNeeded方法,会立即触发调用layoutSubviews方法
 
 [self setNeedsLayout];
 只调用setNeedsLayout方法,会在下一个刷新周期触发调用layoutSubviews方法
 
 [self setNeedsDisplay];
 只调用setNeedsDisplay方法,会在下一个刷新周期触发调用drawRect:方法
 */

@interface PBCellHeightController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBCellHeightController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
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
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    NSMutableString *mutableStr = [NSMutableString stringWithFormat:@""];
    NSArray *titleArr = @[@"frame布局，手动算高_viewModel",
                          @"frame布局，通用手动算高",
                          @"frame布局，手动算高",
                          @"frame布局，自动算高",
                          @"autolayout布局，手动算高",
                          @"autolayout布局，自动算高",
                          @"frame布局，通用手动算高_UICollectionView",
                          @"WaterfallLayout瀑布流_UICollectionView",
                          @"Cycle无限轮播_UICollectionView"];
    [mutableStr appendString:titleArr[indexPath.row]];
    cell.textLabel.text = mutableStr;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *vcArr = @[@"PBCellHeightFiveController",
                       @"PBCellHeightZeroController",
                       @"PBCellHeightOneController",
                       @"PBCellHeightTwoController",
                       @"PBCellHeightThreeController",
                       @"PBCellHeightFourController",
                       @"PBCellHeightCollectionZeroController",
                       @"PBCellHeightCollectionOneController",
                       @"PBCellHeightCollectionTwoController"];
    Class aClass = NSClassFromString(vcArr[indexPath.row]);
    UIViewController *testListController = [[aClass alloc]init];
    
    [self.navigationController pushViewController:testListController animated:YES];
    testListController.view.backgroundColor = [UIColor whiteColor];
}

@end
