//
//  PBStorageZeroController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageZeroController.h"
#import "PBStorageDataBaseController.h"
#import "PBStorageDataBaseOneController.h"
#import "PBStorageDataBaseTwoController.h"

@interface PBStorageZeroController ()

@property (nonatomic, strong) NSArray *objs;

@end

@implementation PBStorageZeroController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"DataBaseFile";
    self.tabBarController.navigationItem.title = @"DataBaseFile";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    self.objs = @[@"数据库常用SQL语句使用", @"数据库存储", @"数据库存储多线程"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    cell.textLabel.text = self.objs[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        PBStorageDataBaseController *testListController = [[PBStorageDataBaseController alloc]init];
        testListController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.row == 1) {
        PBStorageDataBaseOneController *testListOneController = [[PBStorageDataBaseOneController alloc]init];
        testListOneController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testListOneController animated:YES];
        testListOneController.view.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.row == 2) {
        PBStorageDataBaseTwoController *testListTwoController = [[PBStorageDataBaseTwoController alloc]init];
        testListTwoController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testListTwoController animated:YES];
        testListTwoController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
