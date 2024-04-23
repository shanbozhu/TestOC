//
//  PBRuntimeController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeController.h"

@interface PBRuntimeController ()

@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

@implementation PBRuntimeController

- (NSArray *)titleArr {
    if (!_titleArr) {
        _titleArr = @[@"hook方法(方法替换)",
                      @"遍历当前工程的所有类/所有自定义类",
                      @"遍历某类的属性/方法/成员变量/协议",
                      @"遍历某视图的所有子视图",
                      @"获取调用某方法的堆栈",
                      @"消息转发",
                      @"方法调用",
                      @"方法添加"];
    }
    return _titleArr;
}

- (NSArray *)vcArr {
    if (!_vcArr) {
        _vcArr = @[@"PBRuntimeZeroController",
                   @"PBRuntimeOneController",
                   @"PBRuntimeTwoController",
                   @"PBRuntimeThreeController",
                   @"PBRuntimeFourController",
                   @"PBRuntimeFiveController",
                   @"PBRuntimeSixController",
                   @"PBRuntimeSevenController"];
    }
    return _vcArr;
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
