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

@property (nonatomic, strong) NSArray *arr;

@end

/**
 同步:阻塞当前线程.用于修饰方法,如"这是一个同步方法"
 异步:不阻塞当前线程.用于修饰方法,如"这是一个异步方法"
 
 并行:允许同时执行.满足同时执行时,开辟子线程;不满足同时执行时,不开辟子线程
 串行:不同时执行,不开辟子线程
 
 不同线程队列之间是并行的
 */

@implementation PBGCDZeroController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"多线程";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    NSArray *arr = @[@"(0)dispatch_group_enter",
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
    self.arr = arr;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    cell.textLabel.text = self.arr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        PBGCDListController *testListController = [[PBGCDListController alloc] init];
        testListController.hidesBottomBarWhenPushed = YES;
                
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 1) {
        PBGCDListOneController *testListOneController = [[PBGCDListOneController alloc] init];
        testListOneController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListOneController animated:YES];
        testListOneController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 2) {
        PBGCDListTwoController *testListTwoController = [[PBGCDListTwoController alloc] init];
        testListTwoController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListTwoController animated:YES];
        testListTwoController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 3) {
        PBGCDListThreeController *testListThreeController = [[PBGCDListThreeController alloc] init];
        testListThreeController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListThreeController animated:YES];
        testListThreeController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 4) {
        PBGCDListFourController *testListFourController = [[PBGCDListFourController alloc] init];
        testListFourController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListFourController animated:YES];
        testListFourController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 5) {
        PBGCDListFiveController *testListFiveController = [[PBGCDListFiveController alloc] init];
        testListFiveController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListFiveController animated:YES];
        testListFiveController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 6) {
        PBGCDListSixController *testListSixController = [[PBGCDListSixController alloc] init];
        testListSixController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListSixController animated:YES];
        testListSixController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 7) {
        PBGCDListSevenController *testListSevenController = [[PBGCDListSevenController alloc] init];
        testListSevenController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListSevenController animated:YES];
        testListSevenController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 8) {
        PBGCDListEightController *testListEightController = [[PBGCDListEightController alloc] init];
        testListEightController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListEightController animated:YES];
        testListEightController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 9) {
        PBGCDListNineController *testListNineController = [[PBGCDListNineController alloc] init];
        testListNineController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListNineController animated:YES];
        testListNineController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 10) {
        PBGCDListTenController *testListTenController = [[PBGCDListTenController alloc] init];
        testListTenController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListTenController animated:YES];
        testListTenController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 11) {
        PBGCDListElevenController *testListElevenController = [[PBGCDListElevenController alloc] init];
        testListElevenController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListElevenController animated:YES];
        testListElevenController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 12) {
        PBGCDListTwelveController *testListTwelveController = [[PBGCDListTwelveController alloc] init];
        testListTwelveController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListTwelveController animated:YES];
        testListTwelveController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 13) {
        PBGCDListThirteenController *testListThirteenController = [[PBGCDListThirteenController alloc] init];
        testListThirteenController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListThirteenController animated:YES];
        testListThirteenController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 14) {
        PBGCDListFourteenController *testListFourteenController = [[PBGCDListFourteenController alloc] init];
        testListFourteenController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testListFourteenController animated:YES];
        testListFourteenController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
