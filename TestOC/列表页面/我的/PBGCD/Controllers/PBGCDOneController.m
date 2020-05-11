//
//  PBGCDOneController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/10/30.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBGCDOneController.h"
#import "PBGCDLockController.h"
#import "PBGCDLockOneController.h"
#import "PBGCDLockTwoController.h"
#import "PBGCDLockThreeController.h"
#import "PBGCDLockFourController.h"
#import "PBGCDLockFiveController.h"
#import "PBGCDLockSixController.h"
#import "PBGCDLockSevenController.h"
#import "PBGCDLockEightController.h"
#import "PBGCDLockNineController.h"
#import "PBGCDLockTenController.h"

@interface PBGCDOneController ()

@property (nonatomic, strong) NSArray *arr;

@end

@implementation PBGCDOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"线程同步";
    
    self.tableView.tableFooterView = [[UIView alloc] init];

    NSArray *arr = @[@"(0)不加锁",
                     @"(1)NSLock",
                     @"(2)NSCondition",
                     @"(3)NSConditionLock",
                     @"(4)NSRecursiveLock",
                     @"(5)pthread_mutex_t",
                     @"(6)OSSpinLockLock",
                     @"(7)@synchronized",
                     @"(8)dispatch_barrier_async",
                     @"(9)dispatch_semaphore_t",
                     @"(10)pthread_rwlock_t"];
    self.arr = arr;

    // 性能比较:
    // OSSpinLockLock > dispatch_semaphore_t > dispatch_barrier_async > pthread_rwlock_t > pthread_mutex_t > NSLock > NSCondition > NSRecursiveLock > NSConditionLock > synchronized
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
        PBGCDLockController *testLockController = [[PBGCDLockController alloc] init];
        testLockController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockController animated:YES];
        testLockController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 1) {
        PBGCDLockOneController *testLockOneController = [[PBGCDLockOneController alloc] init];
        testLockOneController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockOneController animated:YES];
        testLockOneController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 2) {
        PBGCDLockTwoController *testLockTwoController = [[PBGCDLockTwoController alloc] init];
        testLockTwoController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockTwoController animated:YES];
        testLockTwoController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 3) {
        PBGCDLockThreeController *testLockThreeController = [[PBGCDLockThreeController alloc] init];
        testLockThreeController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockThreeController animated:YES];
        testLockThreeController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 4) {
        PBGCDLockFourController *testLockFourController = [[PBGCDLockFourController alloc] init];
        testLockFourController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockFourController animated:YES];
        testLockFourController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 5) {
        PBGCDLockFiveController *testLockFiveController = [[PBGCDLockFiveController alloc] init];
        testLockFiveController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockFiveController animated:YES];
        testLockFiveController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 6) {
        PBGCDLockSixController *testLockSixController = [[PBGCDLockSixController alloc] init];
        testLockSixController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockSixController animated:YES];
        testLockSixController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 7) {
        PBGCDLockSevenController *testLockSevenController = [[PBGCDLockSevenController alloc] init];
        testLockSevenController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockSevenController animated:YES];
        testLockSevenController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 8) {
        PBGCDLockEightController *testLockEightController = [[PBGCDLockEightController alloc] init];
        testLockEightController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockEightController animated:YES];
        testLockEightController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 9) {
        PBGCDLockNineController *testLockNineController = [[PBGCDLockNineController alloc] init];
        testLockNineController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockNineController animated:YES];
        testLockNineController.view.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 10) {
        PBGCDLockTenController *testLockTenController = [[PBGCDLockTenController alloc] init];
        testLockTenController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:testLockTenController animated:YES];
        testLockTenController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
