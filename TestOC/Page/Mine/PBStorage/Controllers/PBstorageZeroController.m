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
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

@implementation PBStorageZeroController

- (NSArray *)titleArr {
    if (!_titleArr) {
        _titleArr = @[@"数据库常用SQL语句使用",
                      @"数据库存储",
                      @"数据库存储多线程"];
    }
    return _titleArr;
}

- (NSArray *)vcArr {
    if (!_vcArr) {
        _vcArr = @[@"PBStorageDataBaseController",
                   @"PBStorageDataBaseOneController",
                   @"PBStorageDataBaseTwoController"];
    }
    return _vcArr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"DataBaseFile";
    self.tabBarController.navigationItem.title = @"DataBaseFile";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.vcArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    cell.detailTextLabel.text = self.vcArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Class aClass = NSClassFromString(self.vcArr[indexPath.row]);
    UIViewController *testListController = [[aClass alloc]init];
    
    [self.navigationController pushViewController:testListController animated:YES];
    testListController.view.backgroundColor = [UIColor whiteColor];
}

@end
