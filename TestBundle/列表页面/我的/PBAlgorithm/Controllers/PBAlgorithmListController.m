//
//  PBAlgorithmListController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAlgorithmListController.h"
#import "YYFPSLabel.h"
#import "NSArray+PBSort.h"

@interface PBAlgorithmListController ()

@end

@implementation PBAlgorithmListController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"冒泡排序";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"选择排序";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"插入排序";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"归并排序";
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"快速排序";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        NSMutableArray *objs = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            [objs addObject:[NSNumber numberWithInteger:arc4random_uniform(100)]];
        }
        NSLog(@"objs = %@, arr = %@", objs, [objs pb_bubbleSort]);
    } else if (indexPath.row == 1) {
        NSMutableArray *objs = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            [objs addObject:[NSNumber numberWithInteger:arc4random_uniform(100)]];
        }
        NSLog(@"objs = %@, arr = %@", objs, [objs pb_selectSort]);
    } else if (indexPath.row == 2) {
        NSMutableArray *objs = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            [objs addObject:[NSNumber numberWithInteger:arc4random_uniform(100)]];
        }
        NSLog(@"objs = %@, arr = %@", objs, [objs pb_insertSort]);
    } else if (indexPath.row == 3) {
        
    } else if (indexPath.row == 4) {
        NSMutableArray *objs = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            [objs addObject:[NSNumber numberWithInteger:arc4random_uniform(100)]];
        }
        NSLog(@"objs = %@, arr = %@", objs, [objs pb_quickSort]);
    }
}

@end
