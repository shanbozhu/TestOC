//
//  PBWebViewController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBWebViewController.h"
#import "PBUIWebViewController.h"
#import "PBWKWebViewController.h"

@interface PBWebViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation PBWebViewController

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
        PBUIWebViewController *testListController = [[PBUIWebViewController alloc]init];
        testListController.hidesBottomBarWhenPushed = YES;
        
        testListController.urlStr = @"https://ticketbusinesswap.damai.cn/ticketbusiness-wap/validsetting/toValidSettingsIndex";
        
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.row == 1) {
        PBWKWebViewController *testListOneController = [[PBWKWebViewController alloc]init];
        testListOneController.hidesBottomBarWhenPushed = YES;
        
        testListOneController.urlStr = @"https://x.damai.cn/markets/sport/app?wh_ttid=phone&loginkey=&osType=3&phoneModels=x86_64&clientGUID=E0C3A968-82EB-4A71-900C-14B4884FE9F8&systemVersion=11.2&appType=1&timestamp=1514863554&sign=0c773fde0c311509536620fce2b726b4";
        
        [self.navigationController pushViewController:testListOneController animated:YES];
        testListOneController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
