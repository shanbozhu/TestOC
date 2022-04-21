//
//  PBArrayDeleteController.m
//  TestOC
//
//  Created by shanbo on 2022/4/20.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBArrayDeleteController.h"

@interface PBArrayDeleteController ()

@end

@implementation PBArrayDeleteController

- (void)viewDidLoad {
    [super viewDidLoad];

    {
        // 正序
        NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            if (![str isEqualToString:@"1"]) {
                [arr removeObject:str]; // 不会崩溃,但是删除不干净
                //[arr removeObjectAtIndex:i]; // 不会崩溃,但是删除不干净
            }
        }
        NSLog(@"arr = %@", arr);
        
        // 倒序 推荐
        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        for (int i = (int)arr1.count - 1; i > 0; i--) {
            NSString *str = arr1[i];
            if (![str isEqualToString:@"1"]) {
                [arr1 removeObject:str]; // 支持
                //[arr1 removeObjectAtIndex:i]; // 支持
            }
        }
        NSLog(@"arr1 = %@", arr1);
        
        // 临时数组
        NSMutableArray *arr2 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        NSMutableArray *tmpArr = [arr2 mutableCopy];
        for (int i = 0; i < tmpArr.count; i++) {
            NSString *str = tmpArr[i];
            if (![str isEqualToString:@"1"]) {
                [arr2 removeObject:str]; // 支持
                //[arr2 removeObjectAtIndex:[arr2 indexOfObject:str]]; // 支持
            }
        }
        NSLog(@"arr2 = %@", arr2);
    }

    {
        // 正序
        NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = (NSString *)obj;
            if (![str isEqualToString:@"1"]) {
                [arr removeObject:str]; // 不会崩溃,但是删除不干净
                //[arr removeObjectAtIndex:idx]; // 不会崩溃,但是删除不干净
            }
        }];
        NSLog(@"arr = %@", arr);
        
        // 倒序 推荐
        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        [arr1 enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = (NSString *)obj;
            if (![str isEqualToString:@"1"]) {
                [arr1 removeObject:str]; // 支持
                //[arr1 removeObjectAtIndex:idx]; // 支持
            }
        }];
        NSLog(@"arr1 = %@", arr1);
        
        // 临时数组
        NSMutableArray *arr2 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        NSMutableArray *tmpArr = arr2.mutableCopy;
        [tmpArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = (NSString *)obj;
            if (![str isEqualToString:@"1"]) {
                [arr2 removeObject:str]; // 支持
                //[arr2 removeObjectAtIndex:[arr2 indexOfObject:str]]; // 支持
            }
        }];
        NSLog(@"arr2 = %@", arr2);
    }

    {
        // 正序
        NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        for (NSString *str in arr) {
            if (![str isEqualToString:@"1"]) {
                //[arr removeObject:str]; // 崩溃
                //[arr removeObjectAtIndex:[arr indexOfObject:str]]; // 崩溃
            }
        }
        NSLog(@"arr = %@", arr);
        
        // 倒序
        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        for (NSString *str in arr1.reverseObjectEnumerator) {
            if ([str isEqualToString:@"1"]) {
                //[arr1 removeObject:str]; // 崩溃
                [arr1 removeObjectAtIndex:[arr1 indexOfObject:str]]; // 支持
            }
        }
        NSLog(@"arr1 = %@", arr1);
        
        // 临时数组
        NSMutableArray *arr2 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        NSMutableArray *tmpArr = arr2.mutableCopy;
        for (NSString *str in tmpArr) {
            if (![str isEqualToString:@"1"]) {
                [arr2 removeObject:str]; // 支持
                //[arr2 removeObjectAtIndex:[arr2 indexOfObject:str]]; // 支持
            }
        }
        NSLog(@"arr2 = %@", arr2);
    }

    // 推荐
    NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i = 0; i < arr.count; i++) {
        NSString *str = arr[i];
        if (![str isEqualToString:@"1"]) {
            [indexSet addIndex:i];
        }
    }
    [arr removeObjectsAtIndexes:indexSet];
    NSLog(@"arr = %@", arr);
}

@end
