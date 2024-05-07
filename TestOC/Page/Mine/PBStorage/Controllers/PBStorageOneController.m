//
//  PBStorageOneController.m
//  TestOC
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

@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

@implementation PBStorageOneController

- (NSArray *)titleArr {
    if (!_titleArr) {
        _titleArr = @[@"NSUserDefaults",
                      @"plist(向空文件中存储字典或数组)",
                      @"plist多线程",
                      @"textfile(向空文件中存储字符串)"];
    }
    return _titleArr;
}

- (NSArray *)vcArr {
    if (!_vcArr) {
        _vcArr = @[@"PBStorageTextOneController",
                   @"PBStorageTextTwoController",
                   @"PBStorageTextThreeController",
                   @"PBStorageTextFourController"];
    }
    return _vcArr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"TextFile";
    self.title = @"TextFile";
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
    if (!cell) {
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
