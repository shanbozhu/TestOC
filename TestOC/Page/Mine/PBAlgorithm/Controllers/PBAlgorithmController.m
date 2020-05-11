//
//  PBAlgorithmController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAlgorithmController.h"
#import "PBAlgorithmListController.h"

@interface PBAlgorithmController ()

@end

@implementation PBAlgorithmController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"排序算法";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"查找算法";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        PBAlgorithmListController *testListController = [[PBAlgorithmListController alloc]init];
        testListController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row == 1) {
        
    }
}

@end
