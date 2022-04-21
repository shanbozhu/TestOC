//
//  PBArrayDeleteController.m
//  TestOC
//
//  Created by shanbo on 2022/4/20.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBArrayDeleteController.h"

#define ARRAY @[@"1", @"2", @"3", @"1"]

@interface PBArrayDeleteController ()

@end

@implementation PBArrayDeleteController

- (void)viewDidLoad {
    [super viewDidLoad];

    {
        // 正序
        NSMutableArray *arr = [NSMutableArray arrayWithArray:ARRAY];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            if (![str isEqualToString:@"1"]) {
                [arr removeObject:str]; // 不会崩溃,但是删除不干净
                //[arr removeObjectAtIndex:i]; // 不会崩溃,但是删除不干净
            }
        }
        NSLog(@"0 arr = %@", arr);
        
        // 倒序【推荐】
        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:ARRAY];
        for (int i = (int)arr1.count - 1; i > 0; i--) {
            NSString *str = arr1[i];
            if (![str isEqualToString:@"1"]) {
                [arr1 removeObject:str]; // 支持
                //[arr1 removeObjectAtIndex:i]; // 支持
            }
        }
        NSLog(@"0 arr1 = %@", arr1);
        
        // 临时数组【推荐】
        NSMutableArray *arr2 = [NSMutableArray arrayWithArray:ARRAY];
        NSMutableArray *tmpArr = [arr2 mutableCopy];
        for (int i = 0; i < tmpArr.count; i++) {
            NSString *str = tmpArr[i];
            if (![str isEqualToString:@"1"]) {
                [arr2 removeObject:str]; // 支持
                //[arr2 removeObjectAtIndex:[arr2 indexOfObject:str]]; // 支持
            }
        }
        NSLog(@"0 arr2 = %@", arr2);
    }

    {
        // 正序
        NSMutableArray *arr = [NSMutableArray arrayWithArray:ARRAY];
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = (NSString *)obj;
            if (![str isEqualToString:@"1"]) {
                [arr removeObject:str]; // 不会崩溃,但是删除不干净
                //[arr removeObjectAtIndex:idx]; // 不会崩溃,但是删除不干净
            }
        }];
        NSLog(@"1 arr = %@", arr);
        
        // 倒序【推荐】
        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:ARRAY];
        [arr1 enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = (NSString *)obj;
            if (![str isEqualToString:@"1"]) {
                [arr1 removeObject:str]; // 支持
                //[arr1 removeObjectAtIndex:idx]; // 支持
            }
        }];
        NSLog(@"1 arr1 = %@", arr1);
        
        // 临时数组【推荐】
        NSMutableArray *arr2 = [NSMutableArray arrayWithArray:ARRAY];
        NSMutableArray *tmpArr = arr2.mutableCopy;
        [tmpArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = (NSString *)obj;
            if (![str isEqualToString:@"1"]) {
                [arr2 removeObject:str]; // 支持
                //[arr2 removeObjectAtIndex:[arr2 indexOfObject:str]]; // 支持
            }
        }];
        NSLog(@"1 arr2 = %@", arr2);
    }

    {
        // 正序
        NSMutableArray *arr = [NSMutableArray arrayWithArray:ARRAY];
        for (NSString *str in arr) {
            if (![str isEqualToString:@"1"]) {
                //[arr removeObject:str]; // 崩溃
                //[arr removeObjectAtIndex:[arr indexOfObject:str]]; // 崩溃
            }
        }
        NSLog(@"2 arr = %@", arr);
        
        // 倒序
        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:ARRAY];
        for (NSString *str in arr1.reverseObjectEnumerator) {
            if ([str isEqualToString:@"1"]) {
                //[arr1 removeObject:str]; // 崩溃
                [arr1 removeObjectAtIndex:[arr1 indexOfObject:str]]; // 支持
            }
        }
        NSLog(@"2 arr1 = %@", arr1);
        
        // 临时数组【推荐】
        NSMutableArray *arr2 = [NSMutableArray arrayWithArray:ARRAY];
        NSMutableArray *tmpArr = arr2.mutableCopy;
        for (NSString *str in tmpArr) {
            if (![str isEqualToString:@"1"]) {
                [arr2 removeObject:str]; // 支持
                //[arr2 removeObjectAtIndex:[arr2 indexOfObject:str]]; // 支持
            }
        }
        NSLog(@"2 arr2 = %@", arr2);
    }

    //【强烈推荐】
    NSMutableArray *arr = [NSMutableArray arrayWithArray:ARRAY];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i = 0; i < arr.count; i++) {
        NSString *str = arr[i];
        if (![str isEqualToString:@"1"]) {
            [indexSet addIndex:i]; // 支持
        }
    }
    [arr removeObjectsAtIndexes:indexSet];
    NSLog(@"arr = %@", arr);
}

@end
