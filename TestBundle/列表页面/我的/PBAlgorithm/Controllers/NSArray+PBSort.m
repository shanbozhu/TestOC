//
//  NSArray+PBSort.m
//  TestBundle
//
//  Created by DaMaiIOS on 2018/6/28.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "NSArray+PBSort.h"

@implementation NSArray (PBSort)

// 冒泡排序
- (NSArray *)pb_bubbleSort {
    NSMutableArray *objs = [NSMutableArray arrayWithArray:self];
    {
        for (int i = 0; i < objs.count - 1; i++) {
            for (int j = 0; j < objs.count - 1 -i; j++) {
                if ([objs[j] integerValue] > [objs[j+1] integerValue]) {
                    NSNumber *tmp = objs[j];
                    objs[j] = objs[j+1];
                    objs[j+1] = tmp;
                }
            }
        }
    }
    return objs;
}

// 选择排序
- (NSArray *)pb_selectSort {
    NSMutableArray *objs = [NSMutableArray arrayWithArray:self];
    {
        for (int i = 0; i < objs.count-1; i++) {
            int min = i;
            for (int j = i + 1; j < objs.count; j++) {
                if ([objs[j] integerValue] < [objs[min] integerValue]) {
                    min = j;
                }
            }
            if (min != i) {
                NSNumber *tmp = objs[min];
                objs[min] = objs[i];
                objs[i] = tmp;
            }
        }
    }
    return objs;
}

// 插入排序
- (NSArray *)pb_insertSort {
    NSMutableArray *objs = [NSMutableArray arrayWithArray:self];
    {
        for (int i = 1; i < objs.count; i++) {
            NSNumber *tmp = objs[i];
            int j;
            for (j = i - 1; j >= 0 && [objs[j] integerValue] > [tmp integerValue]; j--) {
                objs[j+1] = objs[j];
            }
            objs[j+1] = tmp;
        }
    }
    return objs;
}

// 快速排序
- (NSArray *)pb_quickSort {
    return [self pb_quickSort:[NSMutableArray arrayWithArray:self] start:0 end:self.count-1];
}

- (NSArray *)pb_quickSort:(NSMutableArray *)objs start:(NSInteger)start end:(NSInteger)end {
    {
        NSInteger last, i;
        if (start >= end) {
            return objs; // 此处只是拦截操作,返回什么下面都没有[接收一下], 所以为nil也可以的
        }
        NSNumber *tmp = objs[start];
        objs[start] = objs[(start + end) / 2];
        objs[(start + end) / 2] = tmp;
        
        last = start;
        for (i = start + 1; i <= end; i++) {
            if (objs[i] < objs[start]) {
                ++last;
                tmp = objs[last];
                objs[last] = objs[i];
                objs[i] = tmp;
            }
        }
        tmp = objs[last];
        objs[last] = objs[start];
        objs[start] = tmp;
        
        [self pb_quickSort:objs start:start end:last-1]; // 没有[接收一下]
        [self pb_quickSort:objs start:last+1 end:end]; // 没有[接收一下]
    }
    return objs;
}

@end
