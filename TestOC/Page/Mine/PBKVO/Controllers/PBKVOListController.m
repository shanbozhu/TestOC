//
//  PBKVOListController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBKVOListController.h"
#import "YYFPSLabel.h"
#import "PBKVOList.h"

@implementation PBKVOListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 40);
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn setTitle:@"点我改变被监控对象的属性值" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // kvo
    [self.testList addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)btnClick:(UIButton *)btn {
    // 修改对象的属性值
    self.testList.name = @"worldhello";
    NSLog(@"self.testList.name = %@", self.testList.name);
}

// kvo响应方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"change = %@", change[@"new"]);
}

- (void)dealloc {
    [self.testList removeObserver:self forKeyPath:@"name" context:nil];
    NSLog(@"PBKVOListController对象被释放了");
}

@end
