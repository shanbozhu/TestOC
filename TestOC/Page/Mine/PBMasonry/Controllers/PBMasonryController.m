//
//  PBMasonryController.m
//  TestOC
//
//  Created by shanbo on 2022/5/7.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBMasonryController.h"
#import "PBMasonryOneController.h"
#import "PBMasonryTwoController.h"

/**
 // 添加约束
 - (NSArray *)mas_makeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block;
 // 更新(某一个)约束
 - (NSArray *)mas_updateConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block;
 // 重新添加约束
 - (NSArray *)mas_remakeConstraints:(void(NS_NOESCAPE ^)(MASConstraintMaker *make))block;
 
 equalTo()       参数是对象类型。传入视图对象或坐标系对象
 mas_equalTo()   参数是对象类型和基本类型
 
 offset()        参数是基本类型。传入偏移量：上、左是正数，下、右是负数
 mas_offset()    参数是对象类型和基本类型
 
 假设view的父视图是self(self可以替换为其他任意视图)，则下面语句等价：
 make.top.mas_equalTo(self.mas_top).with.offset(10); // 制造顶部等于self的顶部偏移10
 make.top.mas_equalTo(self.mas_top).offset(10); // 【推荐】
 make.top.mas_equalTo(self).offset(10);
 make.top.mas_equalTo(10);
 make.top.mas_offset(10);
 
 make.height.mas_equalTo(10);
 make.height.offset(10);
 */

@interface PBMasonryController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation PBMasonryController

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
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        PBMasonryOneController *masonryOneController = [[PBMasonryOneController alloc]init];
        
        [self.navigationController pushViewController:masonryOneController animated:YES];
        masonryOneController.view.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row == 1) {
        PBMasonryTwoController *masonryOneController = [[PBMasonryTwoController alloc]init];
        
        [self.navigationController pushViewController:masonryOneController animated:YES];
        masonryOneController.view.backgroundColor = [UIColor whiteColor];
    }
}


@end
