//
//  PBAlertController.m
//  TestOC
//
//  Created by shanbo on 2024/4/17.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBAlertController.h"

@interface PBAlertController ()

@end

#define kPBAlertControllerTitle @"kPBAlertControllerTitle"
#define kPBAlertControllerMessage @"kPBAlertControllerMessage"

@implementation PBAlertController

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self debugNovelCoreSelectTitleIndustry];
    }  else if (indexPath.row == 1) {
        [self debugNovelCoreSelectTitleChannel];
    }
}

#pragma mark -

- (void)debugNovelCoreSelectTitleIndustry {
    NSArray *objs = @[@"金融保险",
                      @"餐饮",
                      @"文化体育娱乐",
                      @"建筑房地产",
                      @"社会公共管理",
                      @"医药卫生",
                      @"交通运输和仓储邮政",
                      @"法律商务人力外贸",
                      @"住宿旅游",
                      @"纺织服装",
                      @"机械制造",
                      @"家电",
                      @"日化百货",
                      @"生活服务",
                      @"农林牧渔",
                      @"食品加工",
                      @"教育",
                      @"建材家居",
                      @"IT通信电子",
                      @"能源采矿化工",
                      @"汽车",
                      @"广告营销",
                      @"其他"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kPBAlertControllerTitle message:kPBAlertControllerMessage preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancelAction];
    
    for (NSString *title in objs) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alert addAction:alertAction];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)debugNovelCoreSelectTitleChannel {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:kPBAlertControllerTitle message:kPBAlertControllerMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.placeholder = [NSString stringWithFormat:@"请输入用户名:"];
    }];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.placeholder = [NSString stringWithFormat:@"请输入密码:"];
    }];
    UIAlertAction *alertText = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *userTextField = [[alertView textFields] firstObject];
        UITextField *passwordTextField = [[alertView textFields] lastObject];
        NSLog(@"用户名:%@, 密码:%@", userTextField.text, passwordTextField.text);
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:cancleAction];
    [alertView addAction:alertText];
    [self presentViewController:alertView animated:YES completion:nil];
}

@end
