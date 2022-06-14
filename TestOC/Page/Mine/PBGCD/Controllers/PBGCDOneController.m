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

@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

@implementation PBGCDOneController

- (NSArray *)titleArr {
    if (!_titleArr) {
        _titleArr = @[@"(0)不加锁",
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
    }
    return _titleArr;
}

- (NSArray *)vcArr {
    if (!_vcArr) {
        _vcArr = @[@"PBGCDLockController",
                   @"PBGCDLockOneController",
                   @"PBGCDLockTwoController",
                   @"PBGCDLockThreeController",
                   @"PBGCDLockFourController",
                   @"PBGCDLockFiveController",
                   @"PBGCDLockSixController",
                   @"PBGCDLockSevenController",
                   @"PBGCDLockEightController",
                   @"PBGCDLockNineController",
                   @"PBGCDLockTenController"];
    }
    return _vcArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"线程同步";
    
    self.tableView.tableFooterView = [[UIView alloc] init];

    // 性能比较:
    // OSSpinLockLock > dispatch_semaphore_t > dispatch_barrier_async > pthread_rwlock_t > pthread_mutex_t > NSLock > NSCondition > NSRecursiveLock > NSConditionLock > synchronized
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
    if (cell == nil) {
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
