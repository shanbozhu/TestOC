//
//  PBDeviceCheckExampleController.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/8.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBDeviceCheckExampleController.h"
#import "PBDeviceCheckExample.h"

@interface PBDeviceCheckExampleController ()

@property (nonatomic, weak) UITextView *logTextView;
@property (nonatomic, assign) BOOL isRunning;

@end

@implementation PBDeviceCheckExampleController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DeviceCheck 示例";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigationItems];
    [self setupLogTextView];
    [self appendLog:@"点击右上角「运行示例」开始演示 DeviceCheck 工作流。\n\n"
     @"流程：App 生成 Token → 上传服务器 → 服务器请求 Apple → Apple 返回 bit 状态\n"
     @"（不会返回 UDID 等设备标识）\n"];
}

#pragma mark - UI

- (void)setupNavigationItems {
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"运行示例"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(runExample)];
}

- (void)setupLogTextView {
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Menlo-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    textView.textColor = [UIColor darkTextColor];
    textView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    [self.view addSubview:textView];
    self.logTextView = textView;
}

#pragma mark - Actions

- (void)runExample {
    if (self.isRunning) {
        return;
    }
    self.isRunning = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.logTextView.text = @"";
    [self appendLog:@"========== DeviceCheck 工作流示例 ==========\n\n"];
    
    [PBDeviceCheckExample runWorkflowExampleWithProgress:^(PBDeviceCheckStepResult *result) {
        NSString *status = result.isSuccess ? @"✅" : @"❌";
        [self appendLog:[NSString stringWithFormat:@"%@ %@\n%@\n\n────────────────────────\n\n",
                         status, result.stepTitle, result.stepDetail]];
    } completion:^(NSArray<PBDeviceCheckStepResult *> *allSteps, NSError *error) {
        self.isRunning = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (error) {
            [self appendLog:[NSString stringWithFormat:@"流程结束（有错误）：%@\n", error.localizedDescription]];
        } else {
            [self appendLog:@"流程演示完成。\n真机环境下 Step 1 会生成真实 Token；Step 2~4 为服务端逻辑说明与模拟。"];
        }
    }];
}

- (void)appendLog:(NSString *)text {
    self.logTextView.text = [self.logTextView.text stringByAppendingString:text ?: @""];
    if (self.logTextView.text.length > 0) {
        NSRange bottom = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:bottom];
    }
}

@end
