//
//  PBStorageController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/8/5.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBStorageController.h"
#import "PBStorageZeroController.h"
#import "PBStorageOneController.h"
#import "PBSandBox.h"
#import "PBArchiver.h"

@interface PBStorageController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *vcArr;

@end

@implementation PBStorageController

- (NSArray *)titleArr {
    if (!_titleArr) {
        _titleArr = @[@"BinaryFile",
                      @"TextFile"];
    }
    return _titleArr;
}

- (NSArray *)vcArr {
    if (!_vcArr) {
        _vcArr = @[@"PBStorageZeroController",
                   @"PBStorageOneController"];
    }
    return _vcArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.tableView.tableFooterView = [UIView new];
    
    // 应用安装目录 /var/containers/Bundle/Application/203A6137-DA6D-4B7B-9163-20B3C801833D/TestOC.app
    NSLog(@"[NSBundle mainBundle].bundlePath = %@", [NSBundle mainBundle].bundlePath);
    // 应用沙盒目录 /var/mobile/Containers/Data/Application/6EB3CEC1-4D63-458E-97DD-3EDD686252D8
    NSLog(@"[PBSandBox path4Home] = %@", [PBSandBox path4Home]);
    
    // 字符串
    {
        // 增
        {
            NSString *str = HELLOWORLD;
            NSString *newStr = [str stringByAppendingString:HELLOWORLD];
            NSLog(@"newStr = %@", newStr);
        }
        
        // 删
        {
            NSString *str = HELLOWORLD;
            NSMutableString *newStr = [NSMutableString string];
            for (int i = 0; i < str.length; i++) {
                unichar character = [str characterAtIndex:i];
                if (character == 'o') {
                    continue;
                }
                [newStr appendString:[NSString stringWithFormat:@"%c", character]];
            }
            NSLog(@"newStr = %@", newStr);
        }
        
        // 改
        {
            NSString *str = HELLOWORLD;
            NSMutableString *newStr = [NSMutableString string];
            for (int i = 0; i < str.length; i++) {
                unichar character = [str characterAtIndex:i];
                if (character == 'o') {
                    [newStr appendString:[NSString stringWithFormat:@"%c", 'O']];
                } else {
                    [newStr appendString:[NSString stringWithFormat:@"%c", character]];
                }
            }
            NSLog(@"newStr = %@", newStr);
        }
        
        // 查
        {
            NSInteger index = 0;
            NSString *str = HELLOWORLD;
            for (int i = 0; i < str.length; i++) {
                unichar character = [str characterAtIndex:i];
                if (character == 'o') {
                    index = i;
                    NSLog(@"index = %ld", index);
                }
            }
        }
    }
    
    // 文本文件
    {
        // 向空文件中存储字符串
        NSString *filePath = [PBSandBox absolutePathWithRelativePath:kPBSTORAGESTR];
        [PBSandBox createFileAtPath:filePath];
        
        NSString *str = HELLOWORLD;
        [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] = %@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
    }
    {
        // 向空文件中存储数组
        NSString *filePath = [PBSandBox absolutePathWithRelativePath:kPBSTORAGEARR];
        [PBSandBox createFileAtPath:filePath];
        
        NSArray *arr = @[@"1", @"2"];
        [arr writeToFile:filePath atomically:YES];
        NSLog(@"[NSArray arrayWithContentsOfFile:filePath] = %@", [NSArray arrayWithContentsOfFile:filePath]);
        
        //
        NSLog(@"[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] = %@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
    }
    {
        // 向空文件中存储字典
        NSString *filePath = [PBSandBox absolutePathWithRelativePath:kPBSTORAGEDICT];
        [PBSandBox createFileAtPath:filePath];
        
        NSDictionary *dict = @{@"1": @"2"};
        [dict writeToFile:filePath atomically:YES];
        NSLog(@"[NSDictionary dictionaryWithContentsOfFile:filePath] = %@", [NSDictionary dictionaryWithContentsOfFile:filePath]);
        
        //
        NSLog(@"[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] = %@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
    }
    
    // 二进制文件
    {
        // 向空文件中存储二进制
        NSString *filePath = [PBSandBox absolutePathWithRelativePath:kPBSTORAGEDATA];
        [PBSandBox createFileAtPath:filePath];
        
        NSDictionary *dict = @{@"1": @"2", @"3": @"中文"};
        NSData *data = [PBArchiver dataWithObject:dict key:@"dict"];
        [data writeToFile:filePath atomically:YES];
        
        //
        NSLog(@"[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] = %@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
        NSLog(@"[NSData dataWithContentsOfFile:filePath] = %@", [NSData dataWithContentsOfFile:filePath]);
        
        // 使用哪种字符串编码
        NSStringEncoding usedEncoding;
        NSError *error;
        [NSString stringWithContentsOfFile:filePath usedEncoding:&usedEncoding error:&error];
        NSLog(@"usedEncoding = %lu, error = %@", usedEncoding, error);
        
        // 打印出二进制数据的十六进制表示，以便于阅读
        NSMutableString *readStr = [NSMutableString string];
        NSData *readData = [NSData dataWithContentsOfFile:filePath];
        Byte *bytes = (Byte *)readData.bytes;
        NSUInteger length = readData.length;
        for (NSUInteger i = 0; i < length; i++) {
            printf("%02x ", bytes[i]); // 不带换行符
            [readStr appendString:[NSString stringWithFormat:@"%02x ", bytes[i]]];
        }
        printf("\n");
        NSLog(@"readStr = %@", readStr);
        
        // readData
        NSDictionary *readDict = [PBArchiver objectWithData:readData key:@"dict"];
        NSLog(@"readDict = %@", readDict);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.vcArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    cell.detailTextLabel.text = self.vcArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Class aClass = NSClassFromString(self.vcArr[indexPath.row]);
    UIViewController *testListController = [[aClass alloc]init];
    
    [self.navigationController pushViewController:testListController animated:YES];
    testListController.view.backgroundColor = [UIColor whiteColor];
}

@end
