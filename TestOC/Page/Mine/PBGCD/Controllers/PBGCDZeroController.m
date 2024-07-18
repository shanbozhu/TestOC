//
//  PBGCDZeroController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDZeroController.h"
#import "PBGCDListController.h"
#import "PBGCDListOneController.h"
#import "PBGCDListTwoController.h"
#import "PBGCDListThreeController.h"
#import "PBGCDListFourController.h"
#import "PBGCDListFiveController.h"
#import "PBGCDListSixController.h"
#import "PBGCDListSevenController.h"
#import "PBGCDListEightController.h"
#import "PBGCDListNineController.h"
#import "PBGCDListTenController.h"
#import "PBGCDListElevenController.h"
#import "PBGCDListTwelveController.h"
#import "PBGCDListThirteenController.h"
#import "PBGCDListFourteenController.h"

@interface PBGCDZeroController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

/**
 同步：阻塞当前线程。用于修饰方法，如"这是一个同步方法"
 异步：不阻塞当前线程。用于修饰方法，如"这是一个异步方法"
 
 并行：允许同时执行。满足同时执行时，开辟子线程；不满足同时执行时，不开辟子线程
 串行：不同时执行，不开辟子线程
 
 不同线程队列之间是并行的
 */

@implementation PBGCDZeroController

- (NSArray *)titleArr {
    if (!_titleArr) {
        _titleArr = @[@"(0)dispatch_group_enter",
                      @"(1)并行队列 + 同步执行",
                      @"(2)并行队列 + 异步执行",
                      @"(3)全局并行队列 + 同步执行",
                      @"(4)全局并行队列 + 异步执行",
                      @"(5)串行队列 + 同步执行",
                      @"(6)串行队列 + 异步执行",
                      @"(7)主串行队列 + 同步执行",
                      @"(8)主串行队列 + 异步执行",
                      @"(9)线程通信",
                      @"(10)栅栏方法",
                      @"(11)延时方法",
                      @"(12)一次性方法",
                      @"(13)并行遍历",
                      @"(14)队列组"];
    }
    return _titleArr;
}

- (NSArray *)vcArr {
    if (!_vcArr) {
        _vcArr = @[@"PBGCDListController",
                   @"PBGCDListOneController",
                   @"PBGCDListTwoController",
                   @"PBGCDListThreeController",
                   @"PBGCDListFourController",
                   @"PBGCDListFiveController",
                   @"PBGCDListSixController",
                   @"PBGCDListSevenController",
                   @"PBGCDListEightController",
                   @"PBGCDListNineController",
                   @"PBGCDListTenController",
                   @"PBGCDListElevenController",
                   @"PBGCDListTwelveController",
                   @"PBGCDListThirteenController",
                   @"PBGCDListFourteenController"];
    }
    return _vcArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"多线程";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
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
