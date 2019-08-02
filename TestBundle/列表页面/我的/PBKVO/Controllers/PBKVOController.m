//
//  PBKVOController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBKVOController.h"
#import "PBKVOListController.h"
#import "PBKVOList.h"

@interface PBKVOController ()

@property (nonatomic, strong) PBKVOList *testList;

@end

@implementation PBKVOController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(100, 200, ([UIScreen mainScreen].bounds.size.width-100)/2, 50);
    [btn setTitle:@"点我跳转" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:oneBtn];
    oneBtn.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 40);
    oneBtn.backgroundColor = [UIColor lightGrayColor];
    [oneBtn setTitle:@"点我改变被监控对象的属性值" forState:UIControlStateNormal];
    [oneBtn addTarget:self action:@selector(oneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    PBKVOList *testList = [[PBKVOList alloc]init];
    self.testList = testList;
    testList.name = @"helloworld";
    testList.sex = @"man";
}

- (void)btnClick:(UIButton *)btn {
    PBKVOListController *testListController = [[PBKVOListController alloc]init];
    testListController.hidesBottomBarWhenPushed = YES;
    
    testListController.testList = self.testList;
    
    [self.navigationController pushViewController:testListController animated:YES];
    testListController.view.backgroundColor = [UIColor whiteColor];
}

- (void)oneBtnClick:(UIButton *)btn {
    // 修改对象的属性值
    self.testList.name = @"worldhello";
    NSLog(@"self.testList.name = %@", self.testList.name);
}

@end
