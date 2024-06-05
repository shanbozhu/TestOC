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
#import "FileHash.h"
#import "NSString+BBAMD5.h"
#import "PBSandBox.h"
#import "NSString+BBAURL.h"
#import "PBStorageController.h"
#import "PBAnnotationController.h"

// 参考文档:
// 一、消息摘要算法MD5、SHA-1 https://www.jianshu.com/p/38c93c677124

@interface PBNSLogController ()

@end

@implementation PBNSLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 栈上申请的内存不要超过512K，避免发生栈溢出。
    {
        // Bad Case
        //int buf[1024 * 1024]; // 会崩溃
        
        // Good Case
        int *buf = malloc(sizeof(int) * 1024 * 1024);
        *buf = 1; // 首元素
        NSLog(@"sizeof(*buf) = %ld", sizeof(*buf)); // sizeof(*buf) = 4
        NSLog(@"*buf = %d", *buf); // *buf = 1
        NSLog(@"buf[0] = %d", buf[0]); // buf[0] = 1
        NSLog(@"buf[1] = %d", buf[1]); // buf[1] = 0
        NSLog(@"buf[2] = %d", buf[2]); // buf[2] = 0
    }
    {
        int buf[2 * 1024]; // 栈上
        NSLog(@"sizeof(buf) = %ld", sizeof(buf)); // sizeof(buf) = 8192 = 2 * 1024 * 4(B)
        NSLog(@"sizeof(int) = %ld", sizeof(int)); // sizeof(int) = 4
    }
    {
        int *buf = malloc(sizeof(int) * 2 * 1024); // 堆上
        NSLog(@"sizeof(buf) = %ld", sizeof(buf)); // sizeof(buf) = 8
        NSLog(@"sizeof(int) = %ld", sizeof(int)); // sizeof(int) = 4
    }
    
    // 十进制转k进制:除k取余法
    // k进制转十进制:乘以k的次方
    
    // 有效数字:从第一个不是0的数开始,以下都是
    // 00000018.012的有效数字是5
    // 至多保留10位有效数字:%.10g
    
    // 二进制:0b1111
    // 十六进制:0x1f4
    // 八进制:0o764
    
    // 十六进制小写:%x
    // 十六进制大写:%X
    // 八进制:%o
    
    // 总共至少显示12位,前面不足补0,大于12位显示实际位数,小数点后显示3位小数:%012.3lf
    
    //
    CGFloat height = 18.0123456789;
    NSLog(@"height = %lf", height); // 18.012346
    NSLog(@"height = %012.3lf", height); // 00000018.012
    NSLog(@"height = %0.3lf", height); // 18.012
    NSLog(@"height = %.3lf", height); // 18.012
    NSLog(@"height = %e", height); // 1.801235e+01
    NSLog(@"height = %.10g", height); // 18.01234568
    
    //
    NSInteger aa = 500;
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
     -> PBStorage 10:52:02
      $ pwd
     /Users/wsc/Library/Developer/CoreSimulator/Devices/6AED87EE-9937-4DF2-936B-A6E41A4F751E/data/Containers/Data/Application/DF8EFF49-AC1C-4588-9EF1-DA06D4BF0A80/Documents/PBStorage
     -> PBStorage 10:52:16
      $ ls
     PBStorageArr    PBStorageData    PBStorageDict    PBStorageStr
     -> PBStorage 10:52:23
      $ cat PBStorageStr
     helloworld!-> PBStorage 10:52:31
      $ md5 PBStorageStr
     MD5 (PBStorageStr) = 420e57b017066b44e05ea1577f6e2e12
     -> PBStorage 10:52:40
      $ shasum PBStorageStr
     3c608e47152c7b175e9d3c171002dc234bb00953  PBStorageStr
     -> PBStorage 10:52:48
      $ shasum -a 1 PBStorageStr
     3c608e47152c7b175e9d3c171002dc234bb00953  PBStorageStr
     -> PBStorage 10:52:57
      $ shasum -a 256 PBStorageStr
     98d234db7e91f5ba026a25d0d6f17bc5ee0a347ea2216b0c9de06d43536d49f4  PBStorageStr
     -> PBStorage 10:53:07
      $ shasum -a 512 PBStorageStr
     4e6be41aade78bebbe95662312b581088bd860320ed99cfbe5ae8ab8cf355e95f6bac60220bb0dee2d66613111c18f8ce08319d014fbc07e74001693172551c1  PBStorageStr
     */
    // md5  32个字符/2=16byte 16*8=128bit
    // sha1 40个字符/2=20byte 20*8=160bit
    NSString *str = HELLOWORLD;
    NSLog(@"[str bdp_md5Hash] = %@", [str bdp_md5Hash]); // 420e57b017066b44e05ea1577f6e2e12
    NSLog(@"[str bdp_sha1Hash] = %@", [str bdp_sha1Hash]); // 3c608e47152c7b175e9d3c171002dc234bb00953
    
    NSString *filePath = [PBSandBox absolutePathWithRelativePath:kPBSTORAGESTR];
    NSLog(@"[NSString bdp_fileMD5HashCreateWithPath:filePath] = %@", [NSString bdp_fileMD5HashCreateWithPath:filePath]); // 420e57b017066b44e05ea1577f6e2e12
    NSLog(@"[FileHash md5HashOfFileAtPath:filePath] = %@", [FileHash md5HashOfFileAtPath:filePath]); // 420e57b017066b44e05ea1577f6e2e12
    NSString *fileContentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"[fileContentStr bdp_md5Hash] = %@", [fileContentStr bdp_md5Hash]); // 420e57b017066b44e05ea1577f6e2e12
    
    // base64
    NSString *base64Str = [[str dataUsingEncoding:NSUTF8StringEncoding] bdp_base64Encoding];
    NSLog(@"base64Str = %@", base64Str); // aGVsbG93b3JsZCE=
    NSData *data = [NSData bdp_dataWithBase64EncodedString:base64Str];
    NSString *originStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"originStr = %@", originStr); // HELLOWORLD
    
    // urlencode
    NSString *urlStr = kPBBaiduMap;
    NSLog(@"[urlStr bdp_percentEncoding] = %@", [urlStr bdp_percentEncoding]);
    NSLog(@"[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] = %@", [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
    NSLog(@"[urlStr bdp_encodeURIComponent] = %@", [urlStr bdp_encodeURIComponent]);
    NSLog(@"[urlStr bdp_decodeURIComponent] = %@", [urlStr bdp_decodeURIComponent]);
    NSLog(@"[[urlStr bdp_encodeURIComponent] bdp_decodeURIComponent] = %@", [[urlStr bdp_encodeURIComponent] bdp_decodeURIComponent]);
    
    // Unicode
    NSString *contentString = @"你好世界ABC";
    NSMutableString *unicodeStr = [NSMutableString string];
    for (int i = 0; i < contentString.length; i++) {
        unichar character = [contentString characterAtIndex:i];
        [unicodeStr appendFormat:@"\\u%04x", character];
    }
    NSLog(@"unicodeStr = %@", unicodeStr);
    
    NSString *aaaa = @"\u4f60\u597d\u4e16\u754c";
    NSLog(@"aaaa = %@", aaaa);
    UILabel *aaaaLab = [[UILabel alloc] init];
    [self.view addSubview:aaaaLab];
    aaaaLab.frame = CGRectMake(100, 150, 200, 100);
    aaaaLab.numberOfLines = 0;
    aaaaLab.text = aaaa;
    aaaaLab.layer.borderWidth = 1.1;
    aaaaLab.layer.borderColor = [UIColor redColor].CGColor;
}

void printBinary(long num) {
    if (num > 1) {
        printBinary(num >> 1);
    }
    printf("%ld", num & 1);
}

@end
