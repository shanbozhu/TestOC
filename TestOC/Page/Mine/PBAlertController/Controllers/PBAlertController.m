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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
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
    } else if (indexPath.row == 2) {
        [self debugNovelCoreSelectTitleHint];
    }
}

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

- (void)debugNovelCoreSelectTitleHint {
    NSString *message = @"messagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagem\nessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemes\nsagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessage\nmessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagem\nessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemes\nsagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessage\nmessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagem\nessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemes\nsagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessagemessage\n";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [alertControllerMessageStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, message.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, message.length)];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, message.length)];
    //[alert setValue:alertControllerMessageStr forKey:@"_attributedMessage"];
    [alert setValue:alertControllerMessageStr forKey:@"attributedMessage"]; // 与上面调用效果相同, 1.通过设置类的私有属性
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    //UILabel *messageLabel = [alert.view valueForKey:@"_messageLabel"]; // 1.通过设置类的私有属性
    UILabel *messageLabel = alert.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1]; // 2.通过遍历视图的所有子视图,找到要修改的视图
    NSLog(@"messageLabel = %@", messageLabel);
    messageLabel.layer.borderColor = [UIColor blueColor].CGColor;
    messageLabel.layer.borderWidth = 1.1;
}

@end
