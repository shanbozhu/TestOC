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

    NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"1", @"4", @"1", @"4", @"1", @"4", @"1", @"4", @"1", @"4", @"1", @"4"]];
//    for (int i = 0; i < arr.count; i++) {
//        NSString *str = arr[i];
//        if ([str isEqualToString:@"1"]) {
//            [arr removeObject:str];
//        }
//    }
//    NSLog(@"arr = %@", arr);
    
//    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *str = (NSString *)obj;
//        if ([str isEqualToString:@"1"]) {
//            [arr removeObject:str];
//        }
//    }];
//    NSLog(@"arr = %@", arr);
    
//    for (NSString *str in arr) {
//        if ([str isEqualToString:@"1"]) {
//            [arr removeObject:str];
//        }
//    }
//    NSLog(@"arr = %@", arr);
    
//    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
//    for (int i = 0; i < arr.count; i++) {
//        NSString *str = arr[i];
//        if ([str isEqualToString:@"1"]) {
//            [indexSet addIndex:i];
//        }
//    }
//    [arr removeObjectsAtIndexes:indexSet];
//    NSLog(@"arr = %@", arr);
}

@end
