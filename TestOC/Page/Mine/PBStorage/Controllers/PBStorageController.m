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
#import "PBSandBox.h"

@interface PBStorageController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

@implementation PBStorageController

- (NSArray *)titleArr {
    if (!_titleArr) {
        _titleArr = @[@"DataBaseFile",
                      @"TextFile"];
    }
    return _titleArr;
}

- (NSArray *)vcArr {
    if (!_vcArr) {
        _vcArr = @[@"PBStorageZeroController",
                   @"PBStorageOneController"];
    }
    return _vcArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.tableView.tableFooterView = [UIView new];
    
    // 应用安装目录 /var/containers/Bundle/Application/203A6137-DA6D-4B7B-9163-20B3C801833D/TestOC.app
    NSLog(@"[NSBundle mainBundle].bundlePath = %@", [NSBundle mainBundle].bundlePath);
    // 应用沙盒目录 /var/mobile/Containers/Data/Application/6EB3CEC1-4D63-458E-97DD-3EDD686252D8
    NSLog(@"[PBSandBox path4Home] = %@", [PBSandBox path4Home]);
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
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
