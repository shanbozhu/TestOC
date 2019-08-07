//
//  PBStorageOneController.m
//  TestBundle
//
//  Created by DaMaiIOS on 2017/11/15.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageOneController.h"
#import "PBStorageTextController.h"
#import "PBStorageTextOneController.h"
#import "PBStorageTextTwoController.h"
#import "PBStorageTextThreeController.h"
#import "PBStorageTextFourController.h"

@interface PBStorageOneController ()

@property (nonatomic, strong) NSArray *objs;

@end

@implementation PBStorageOneController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"TextFile";
    self.title = @"TextFile";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    self.objs = @[@"NSKeyedArchiver", @"NSUserDefaults", @"plist(向文本文件中存储数组或字典)", @"plist多线程", @"textfile(向文本文件中存储字符串)"];
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
        PBStorageTextController *testTextController = [[PBStorageTextController alloc]init];
        testTextController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testTextController animated:YES];
        testTextController.view.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.row == 1) {
        PBStorageTextOneController *testTextOneController = [[PBStorageTextOneController alloc]init];
        testTextOneController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testTextOneController animated:YES];
        testTextOneController.view.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.row == 2) {
        PBStorageTextTwoController *testTextTwoController = [[PBStorageTextTwoController alloc]init];
        testTextTwoController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testTextTwoController animated:YES];
        testTextTwoController.view.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.row == 3) {
        PBStorageTextThreeController *testTextThreeController = [[PBStorageTextThreeController alloc]init];
        testTextThreeController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testTextThreeController animated:YES];
        testTextThreeController.view.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.row == 4) {
        PBStorageTextFourController *testTextFourController = [[PBStorageTextFourController alloc]init];
        testTextFourController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testTextFourController animated:YES];
        testTextFourController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
