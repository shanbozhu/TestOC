//
//  PBHitTestController.m
//  TestOC
//
//  Created by zhushanbo on 2026/3/23.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBHitTestController.h"
#import "PBHitTestParentView.h"
#import "PBHitTestMyButton.h"

@interface PBHitTestController ()

@end

@implementation PBHitTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PBHitTestParentView *parentView = [[PBHitTestParentView alloc] init];
    [self.view addSubview:parentView];
    parentView.frame = CGRectMake(100, 150, 100, 100);
    parentView.layer.borderColor = [UIColor redColor].CGColor;
    parentView.layer.borderWidth = 1.11;
    
    PBHitTestMyButton *myButton = [PBHitTestMyButton buttonWithType:UIButtonTypeCustom];
    [parentView addSubview:myButton];
    myButton.frame = CGRectMake(25, 25, 50, 50);
    myButton.layer.borderColor = [UIColor blueColor].CGColor;
    myButton.layer.borderWidth = 1.11;
    
    [myButton addTarget:self action:@selector(myBtnClickOn:) forControlEvents:UIControlEventTouchUpInside];
    
    // 子线程开启定时器
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 创建一个定时器
        NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerClick:) userInfo:nil repeats:YES];
        
        // 将定时器添加到 runloop
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:timer forMode:NSRunLoopCommonModes];
        
        // runloop 添加 MachPort 让子线程保活
        [runloop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
        [runloop run];
    });
}

- (void)timerClick:(NSTimer *)timer {
    NSLog(@"timer添加到NSRunLoopCommonModes");
}

- (void)myBtnClickOn:(UIButton *)btn {
    NSLog(@"myBtnClickOn");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"PBHitTestController");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
