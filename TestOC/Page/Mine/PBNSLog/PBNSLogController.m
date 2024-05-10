//
//  PBNSLogController.m
//  TestOC
//
//  Created by shanbo on 2024/5/8.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBNSLogController.h"
#import "NSString+BBAEncode.h"
#import "NSData+BBAEncode.h"

// 参考文档:
// 一、消息摘要算法MD5、SHA-1 https://www.jianshu.com/p/38c93c677124

@interface PBNSLogController ()

@end

@implementation PBNSLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 十进制转k进制:除k取余法
    // k进制转十进制:乘以k的次方
    
    // 有效数字:从第一个不是0的数开始,以下都是
    // 00000018.012的有效数字是5
    
    // 十六进制:0x1f4
    // 八进制:0764
    
    // 十六进制小写:%x
    // 十六进制大写:%X
    // 八进制:%o
    
    // 总共显示12位,前面不足补0,小数点后显示3位小数:%012.3lf
    
    //
    CGFloat height = 18.012345;
    NSLog(@"height = %012.3lf", height); // 00000018.012
    NSLog(@"height = %0.3lf", height); // 18.012
    NSLog(@"height = %.3lf", height); // 18.012
    
    //
    NSUInteger aa = 500;
    NSLog(@"aa = %lx", aa); // 1f4 = 4 * 16^0 + f * 16^1 + 1 * 16^2 = 500
    NSLog(@"aa = %lX", aa); // 1F4
    NSLog(@"aa = %lo", aa); // 764 = 4 * 8^0 + 6 * 8^1 + 7 * 8^2 = 500
    
    //
    printBinary(aa);
    for (int i = 0; i < 16; i++) {
        printBinary(i);
        printf("\n");
    }
    
    /**
     -> 11 21:38:21
      $ cat file
     helloworld!
     -> 11 21:38:31
      $ md5 file
     MD5 (file) = 6bfcc6e97ea949b83ffac53b5ca427a3
     -> 11 21:38:40
      $ shasum file
     60e6fd8ac4942dbc6f90d3d6993508e03436e642  file
     -> 11 21:38:47
      $ shasum -a 1 file
     60e6fd8ac4942dbc6f90d3d6993508e03436e642  file
     -> 11 21:39:17
      $ shasum -a 256 file
     8a26bd96ac27d136e96fd5f8894cd30537b4e19320bdae2213534836bd83d22a  file
     -> 11 21:39:34
      $ shasum -a 512 file
     2758cdd405154adb369f7f4f0e87d265a0b8b737d97474079f58795a1de0df13d3013befc9589d83d2beb107c5269d049f491b159bb0cae9b83d284e8e134ea5  file
     */
    // md5  32个字符/2=16byte 16*8=128bit
    // sha1 40个字符/2=20byte 20*8=160bit
    NSString *str = @"helloworld!";
    NSLog(@"[str bdp_md5Hash] = %@", [str bdp_md5Hash]); // 420e57b017066b44e05ea1577f6e2e12
    NSLog(@"[str bdp_sha1Hash] = %@", [str bdp_sha1Hash]); // 3c608e47152c7b175e9d3c171002dc234bb00953
    
    //
    NSString *base64Str = [[str dataUsingEncoding:NSUTF8StringEncoding] bdp_base64Encoding];
    NSLog(@"base64Str = %@", base64Str); // aGVsbG93b3JsZCE=
}

/**
void printBinary(unsigned int num) {
    NSMutableString *binaryString = [NSMutableString string];
    for (int i = 31; i >= 0; i--) {
        [binaryString appendString:((num & (1 << i)) ? @"1" : @"0")];
        if (i % 4 == 0) {
            [binaryString appendString:@" "];
        }
    }
    NSLog(@"Binary representation of %d is: %@", num, binaryString);
}
 */

void printBinary(unsigned int num) {
    if (num > 1) {
        printBinary(num >> 1);
    }
    printf("%d", num & 1);
}

@end
