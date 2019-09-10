//
//  PBAFNetworkingTwoController.m
//  TestBundle
//
//  Created by DaMaiIOS on 2018/1/18.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBAFNetworkingTwoController.h"
#import "PBDownload.h"

@interface PBAFNetworkingTwoController ()

@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) UILabel *lab;
@property (nonatomic, weak) UIButton *btn;
@property (nonatomic, weak) UIButton *oneBtn;
@property (nonatomic, weak) UIButton *twoBtn;

@property (nonatomic, strong) PBDownload *download;

@end

@implementation PBAFNetworkingTwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //progressView
    UIProgressView *progressView = [[UIProgressView alloc]init];
    self.progressView = progressView;
    [self.view addSubview:progressView];
    progressView.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 20);
    progressView.progress = 0;
    progressView.tintColor = [UIColor redColor];
    progressView.trackTintColor = [UIColor lightGrayColor];
    progressView.transform = CGAffineTransformMakeScale(1.0f, 2.0f);
    
    //lab
    UILabel *lab = [[UILabel alloc]init];
    self.lab = lab;
    [self.view addSubview:lab];
    lab.frame = CGRectMake(20, 130, [UIScreen mainScreen].bounds.size.width-40, 20);
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"0.00%";
    //lab.backgroundColor = [UIColor redColor];
    
    //btn
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn = btn;
    [self.view addSubview:btn];
    btn.frame = CGRectMake(20, 160, [UIScreen mainScreen].bounds.size.width-40, 40);
    [btn setTitle:@"开始下载" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    //btn.backgroundColor = [UIColor redColor];
    btn.tag = 0;
    
    //btn
    UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.oneBtn = btn;
    [self.view addSubview:oneBtn];
    oneBtn.frame = CGRectMake(20, 210, [UIScreen mainScreen].bounds.size.width-40, 40);
    [oneBtn setTitle:@"取消下载" forState:UIControlStateNormal];
    [oneBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [oneBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    //oneBtn.backgroundColor = [UIColor redColor];
    oneBtn.tag = 1;
}

- (void)btnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.tag == 0) {
        if (btn.selected == YES) {
            if ([btn.titleLabel.text isEqualToString:@"开始下载"]) {
                self.download = [PBDownload download];
                __weak typeof(self)weakSelf = self;
                // https://download.sqlitebrowser.org/DB.Browser.for.SQLite-3.11.2.dmg
                [self.download startDownloadWithURL:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg" progress:^(long long currentLength, long long fileLength) {
                    weakSelf.progressView.progress = 1.0 * currentLength / fileLength;
                    weakSelf.lab.text = [NSString stringWithFormat:@"%.2f%%", 100.0 * currentLength / fileLength];
                    if (weakSelf.progressView.progress == 1) {
                        [weakSelf.btn setTitle:@"完成下载" forState:UIControlStateNormal];
                        weakSelf.btn.selected = NO;
                        weakSelf.btn.enabled = NO;
                    }
                }];
            } else {
                [self.download continueDownload];
            }
            
            [btn setTitle:@"暂停下载" forState:UIControlStateNormal];
        } else {
            [self.download suspendDownload];
            
            [btn setTitle:@"继续下载" forState:UIControlStateNormal];
        }
    }
    if (btn.tag == 1) {
        [self.download cancelDownload];
        
        [self.btn setTitle:@"开始下载" forState:UIControlStateNormal];
        self.btn.selected = NO;
        self.btn.enabled = YES;
        
        self.progressView.progress = 0;
        self.lab.text = @"0.00%";
    }
}

- (void)dealloc {
    NSLog(@"PBAFNetworkingTwoController对象被释放了");
}

@end
