//
//  PBAFNetworkingController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAFNetworkingController.h"
#import "PBAFNetworkingZeroController.h"
#import "PBAFNetworkingTwoController.h"

/**
 网络七层分层模型          网络五层分层模型(实际上采用的分层模型)
 
 应用层                  应用层
 表示层
 会话层
 传输层                  传输层
 网络层                  网络层
 数据链路层               数据链路层
 物理层                  物理层
 
 传输层协议主要有tcp和udp
 tcp:面向连接的,可靠的,基于字节流的协议.主要用于文本数据传输
 udp:面向无连接的,不可靠的,基于数据报的协议.主要用于多媒体数据传输
 */

/**
 
                       https基本加解密传输原理
 
            client                              server
                          1.发送https请求
               |---------------------------------->|
               |       2.返回服务器存储的证书公钥       |
               |<----------------------------------|
               |                                   |
               |--------------                     |
               |3.证书校验,产生 |                     |
               |随机对称密钥,使  |                    |
               |用公钥对对称密钥 |                    |
               |加密           |                    |
               |--------------                     |
               |                                   |
               |        4.发送加密后的对称密钥         |
               |---------------------------------->|
               |                                   |
               |                     --------------|
               |                    |5.使用私钥解密获 |
               |                    |取解密后的对称密 |
               |                    |钥,验证hash,使用|
               |                    |私钥加密相应数据 |
               |                     --------------|
               |                                   |
               |        6.返回加密后的相应数据         |
               |<----------------------------------|
               |                                   |
               |--------------                     |
               |7.使用公钥解密成 |                    |
               |功消息,验证hash,|                    |
               |使用对称密钥加密 |                    |
               |真正的数据      |                    |
               |--------------                     |
               |                                   |
               |        8.发送加密后的真正的数据       |
               |---------------------------------->|
               |                                   |
               |                     --------------|
               |                    |9.使用对称密钥解 |
               |                    |密真正的数据,验  |
               |                    |证hash,使用对称 |
               |                    |密钥加密响应数据 |
               |                     --------------|
               |                                   |
               |        10.返回加密后的响应数据        |
               |<----------------------------------|
 
 总结:
 1.使用[非对称加密]加密[对称加密]的密钥,使用[对称加密]加密真正的数据
 2.加密的安全性不在于对加密算法的保护上,而在于对加密密钥的保密上
 3.不可逆加密:只有加密算法,没有解密算法.主要有MD5加密,用于获取数据特征值
 4.对称加密:加密与解密的密钥相同.主要有AES,DES加密
 5.非对称加密:加密与解密是一对公私钥,可以公钥加密,私钥解密,也可以私钥加密,公钥解密.主要有RSA,DSA加密
 6.签名:是对数据特征值进行非对称加密
 */

/**
 网络请求
 方式:GET、POST
 请求:路径、参数、请求头、请求体
 响应:响应头、响应体
 */

@interface PBAFNetworkingController ()

@end

@implementation PBAFNetworkingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 40);
    [btn setTitle:@"点我返回Json" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.backgroundColor = [UIColor grayColor];
    btn.tag = 0;
    
    UIButton *twoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:twoBtn];
    twoBtn.frame = CGRectMake(20, 150, [UIScreen mainScreen].bounds.size.width-40, 40);
    [twoBtn setTitle:@"点我下载文件,支持断点续传和离线下载" forState:UIControlStateNormal];
    [twoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    twoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    twoBtn.backgroundColor = [UIColor grayColor];
    twoBtn.tag = 2;
}

- (void)btnClick:(UIButton *)btn {
    if (btn.tag == 0) {
        PBAFNetworkingZeroController *testListController = [[PBAFNetworkingZeroController alloc]init];
        testListController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testListController animated:YES];
        testListController.view.backgroundColor = [UIColor whiteColor];
    }
    if (btn.tag == 2) {
        PBAFNetworkingTwoController *testListTwoController = [[PBAFNetworkingTwoController alloc]init];
        testListTwoController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testListTwoController animated:YES];
        testListTwoController.view.backgroundColor = [UIColor whiteColor];
    }
}

@end