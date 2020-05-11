//
//  PBStorageController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/8/5.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBStorageController.h"
#import "PBStorageZeroController.h"
#import "PBStorageOneController.h"

@interface PBStorageController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation PBStorageController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        PBStorageZeroController *testListController = [[PBStorageZeroController alloc]init];
        testListController.hidesBottomBarWhenPushed = YES;
                
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.row == 1) {
        PBStorageOneController *testListOneController = [[PBStorageOneController alloc]init];
        testListOneController.hidesBottomBarWhenPushed = YES;
                
        [self.navigationController pushViewController:testListOneController animated:YES];
        testListOneController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
