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
    
    {
        // 向空文件中存储字符串
        NSString *filePath = [PBSandBox absolutePathWithRelativePath:@"/Documents/PBStorage/PBStorageStr"];
        [PBSandBox createFileAtPath:filePath];
        
        NSString *str = @"helloworld!";
        [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] = %@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
    }
    
    {
        // 向空文件中存储字典或数组
        NSString *filePath = [PBSandBox absolutePathWithRelativePath:@"/Documents/PBStorage/PBStorageArr"];
        [PBSandBox createFileAtPath:filePath];
        
        NSArray *arr = @[@"1", @"2"];
        [arr writeToFile:filePath atomically:YES];
        NSLog(@"[NSArray arrayWithContentsOfFile:filePath] = %@", [NSArray arrayWithContentsOfFile:filePath]);
    }
    
    {
        // 向空文件中存储字典
        NSString *filePath = [PBSandBox absolutePathWithRelativePath:@"/Documents/PBStorage/PBStorageDict"];
        [PBSandBox createFileAtPath:filePath];
        
        NSDictionary *dict = @{@"1": @"2"};
        [dict writeToFile:filePath atomically:YES];
        NSLog(@"[NSDictionary dictionaryWithContentsOfFile:filePath] = %@", [NSDictionary dictionaryWithContentsOfFile:filePath]);
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
