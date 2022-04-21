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
        NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            if (![str isEqualToString:@"1"]) {
                //[arr removeObject:str]; // 不会崩溃,但是删除不干净
                [arr removeObjectAtIndex:i]; // 不会崩溃,但是删除不干净
            }
        }
        NSLog(@"arr = %@", arr);
        
        // 推荐
        NSMutableArray *arr6 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        for (int i = (int)arr6.count - 1; i > 0; i--) {
            NSString *str = arr6[i];
            if (![str isEqualToString:@"1"]) {
                [arr6 removeObject:str]; // 支持
                //[arr6 removeObjectAtIndex:i]; // 支持
            }
        }
        NSLog(@"arr6 = %@", arr6);
        
        NSMutableArray *arr9 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        NSMutableArray *tmpArr = [arr9 mutableCopy];
        for (int i = 0; i < tmpArr.count; i++) {
            NSString *str = tmpArr[i];
            if (![str isEqualToString:@"1"]) {
                [arr9 removeObject:str]; // 支持
                //[arr9 removeObjectAtIndex:i]; // 不会崩溃,但是删除不干净
            }
        }
        NSLog(@"arr9 = %@", arr9);
    }

    {
        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        [arr1 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = (NSString *)obj;
            if (![str isEqualToString:@"1"]) {
                [arr1 removeObject:str]; // 不会崩溃,但是删除不干净
                //[arr1 removeObjectAtIndex:idx]; // 不会崩溃,但是删除不干净
            }
        }];
        NSLog(@"arr1 = %@", arr1);
        
        // 推荐
        NSMutableArray *arr7 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        [arr7 enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = (NSString *)obj;
            if (![str isEqualToString:@"1"]) {
                [arr7 removeObject:str]; // 支持
                //[arr7 removeObjectAtIndex:idx]; // 支持
            }
        }];
        NSLog(@"arr7 = %@", arr7);
        
        NSMutableArray *arr2 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        NSMutableArray *tmpArr = arr2.mutableCopy;
        [tmpArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = (NSString *)obj;
            if (![str isEqualToString:@"1"]) {
                [arr2 removeObject:str]; // 支持
                //[arr2 removeObjectAtIndex:idx]; // 不会崩溃,但是删除不干净
            }
        }];
        NSLog(@"arr2 = %@", arr2);
    }

    {
//        NSMutableArray *arr3 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
//        for (NSString *str in arr3) {
//            if (![str isEqualToString:@"1"]) {
//                [arr3 removeObject:str]; // 崩溃
//            }
//        }
//        NSLog(@"arr3 = %@", arr3);
        
//        NSMutableArray *arr8 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
//        for (NSString *str in arr8.reverseObjectEnumerator) {
//            if ([str isEqualToString:@"1"]) {
//                [arr8 removeObject:str]; // 崩溃
//            }
//        }
//        NSLog(@"arr8 = %@", arr8);
        
        NSMutableArray *arr4 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
        NSMutableArray *tmpArr = arr4.mutableCopy;
        for (NSString *str in tmpArr) {
            if (![str isEqualToString:@"1"]) {
                [arr4 removeObject:str]; // 支持
                //[arr4 removeObjectAtIndex:[tmpArr indexOfObject:str]]; // 不会崩溃,但是删除不干净
            }
        }
        NSLog(@"arr4 = %@", arr4);
    }

    // 推荐
    NSMutableArray *arr5 = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1"]];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i = 0; i < arr5.count; i++) {
        NSString *str = arr5[i];
        if (![str isEqualToString:@"1"]) {
            [indexSet addIndex:i];
        }
    }
    [arr5 removeObjectsAtIndexes:indexSet];
    NSLog(@"arr5 = %@", arr5);
}





@end
