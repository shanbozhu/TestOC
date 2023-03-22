//
//  PBQRCodeGenerateController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/8/21.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBQRCodeGenerateController.h"
#import "PBQRCodeGenerate.h"

@interface PBQRCodeGenerateController ()

@end

@implementation PBQRCodeGenerateController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self generateQRCodeDefault];
    [self generateQRCodeWithIcon];
}

- (void)generateQRCodeDefault {
    // imageView
    UIImageView *imageView = [[UIImageView alloc]init];
    [self.view addSubview:imageView];
    imageView.frame = CGRectMake((self.view.frame.size.width-150)/2, APPLICATION_NAVIGATIONBAR_HEIGHT + 10, 150, 150);
    
    imageView.image = [PBQRCodeGenerate qrCodeGenerateWithQRCodeStr:@"http://www.baidu.com" andQRCodeWidth:imageView.frame.size.width];
}

- (void)generateQRCodeWithIcon {
    // imageView
    UIImageView *imageView = [[UIImageView alloc]init];
    [self.view addSubview:imageView];
    imageView.frame = CGRectMake((self.view.frame.size.width-150)/2, 300, 150, 150);
    
    imageView.image = [PBQRCodeGenerate qrCodeGenerateWithQRCodeStr:@"http://www.baidu.com" andIconImage:[UIImage imageNamed:@"pbqrcode_logo"] andIconScale:0.2];
}

@end
