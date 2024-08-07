//
//  PBStorageDataBaseTwoController.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/19.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBStorageDataBaseTwoController.h"
#import "PBDatabase.h"
#import "PBStorageList.h"

@interface PBStorageDataBaseTwoController ()

@end

@implementation PBStorageDataBaseTwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addBtn];
    addBtn.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 40);
    [addBtn setTitle:@"添加数据(增、改)" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtn:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:selectBtn];
    selectBtn.frame = CGRectMake(20, 160, [UIScreen mainScreen].bounds.size.width-40, 40);
    [selectBtn setTitle:@"查找数据(查)" forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    selectBtn.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:deleteBtn];
    deleteBtn.frame = CGRectMake(20, 220, [UIScreen mainScreen].bounds.size.width-40, 40);
    [deleteBtn setTitle:@"删除一条数据(删)" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *deleteAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:deleteAllBtn];
    deleteAllBtn.frame = CGRectMake(20, 280, [UIScreen mainScreen].bounds.size.width-40, 40);
    [deleteAllBtn setTitle:@"删除所有数据(删)" forState:UIControlStateNormal];
    [deleteAllBtn addTarget:self action:@selector(deleteAllBtn:) forControlEvents:UIControlEventTouchUpInside];
    deleteAllBtn.backgroundColor = [UIColor lightGrayColor];
}

- (void)addBtn:(UIButton *)btn {
    // PBStorageList
    PBStorageList *testList = [[PBStorageList alloc]init];
    testList.name = HELLOWORLD;
    testList.age = 100;
    
    for (int i = 0; i < 1000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[PBDatabase sharedDatabase]setValue:testList forKey:[NSString stringWithFormat:@"%d", i]];
        });
    }
}

- (void)selectBtn:(UIButton *)btn {
    for (int i = 0; i < 1000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"%@", [[PBDatabase sharedDatabase]valueForKey:[NSString stringWithFormat:@"%d", i]]);
        });
    }
}

- (void)deleteBtn:(UIButton *)btn {
    for (int i = 0; i < 1000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[PBDatabase sharedDatabase]removeObjectForKey:[NSString stringWithFormat:@"%d", 99]];
        });
    }
}

- (void)deleteAllBtn:(UIButton *)btn {
    for (int i = 0; i < 1000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //[[PBDatabase sharedDatabase]removeAllObjects];
            [[PBDatabase sharedDatabase]removeObjectForKey:[NSString stringWithFormat:@"%d", i]];
        });
    }
}

@end
