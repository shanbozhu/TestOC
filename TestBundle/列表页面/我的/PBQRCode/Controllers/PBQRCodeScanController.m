//
//  PBQRCodeScanController.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/22.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBQRCodeScanController.h"
#import "PBQRCodeScanView.h"
#import "PBTestOneController.h"
#import "PBQRCodeAlbum.h"

@interface PBQRCodeScanController ()<PBQRCodeScanViewDelegate, PBQRCodeAlbumDelegate>

@property (nonatomic, weak) PBQRCodeScanView *qrCodeScanView;

@end

@implementation PBQRCodeScanController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 开始扫描
    [self.qrCodeScanView startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 停止扫描
    [self.qrCodeScanView stopScan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick:)];
    
    // 扫描视图
    PBQRCodeScanView *qrCodeScanView = [PBQRCodeScanView qrCodeScanViewWithFrame:self.view.bounds andCurrentController:self];
    self.qrCodeScanView = qrCodeScanView;
    [self.view addSubview:qrCodeScanView];
    qrCodeScanView.delegate = self;
}

- (void)qrCodeScanView:(PBQRCodeScanView *)qrCodeScanView andDidOutputWithResult:(NSString *)result {
    PBTestOneController *vc = [[PBTestOneController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
    
    vc.desc = result;
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)btn {
    // 照片扫描行为
    PBQRCodeAlbum *qrCodeAlbum = [PBQRCodeAlbum sharedQRCodeAlbum];
    [qrCodeAlbum qrCodeAlbumWithCurrentController:self];
    qrCodeAlbum.delegate = self;
}

- (void)qrCodeAlbum:(PBQRCodeAlbum *)qrCodeAlbum andDidFinishPickingMediaWithResult:(NSString *)result {
    PBTestOneController *vc = [[PBTestOneController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor whiteColor];
    
    vc.desc = result;
}

- (void)dealloc {
    NSLog(@"PBQRCodeScanController对象被释放了");
}

@end
