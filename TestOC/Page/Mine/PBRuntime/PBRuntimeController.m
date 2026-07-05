//
//  PBRuntimeController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/11/4.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeController.h"

@interface PBRuntimeController ()

@property (nonatomic, strong) NSArray *objs;

@end

@implementation PBRuntimeController

- (NSArray *)objs {
    if (!_objs) {
        _objs = @[
            @{
                @"title": @"hook方法(方法替换)",
                @"vc": @"PBRuntimeZeroController"
            },
            @{
                @"title": @"遍历当前工程的所有类/所有自定义类",
                @"vc": @"PBRuntimeOneController"
            },
            @{
                @"title": @"遍历某类的属性/方法/成员变量/协议",
                @"vc": @"PBRuntimeTwoController"
            },
            @{
                @"title": @"遍历某视图的所有子视图",
                @"vc": @"PBRuntimeThreeController"
            },
            @{
                @"title": @"获取调用方法的堆栈",
                @"vc": @"PBRuntimeFourController"
            },
            @{
                @"title": @"消息转发",
                @"vc": @"PBRuntimeFiveController"
            },
            @{
                @"title": @"方法调用",
                @"vc": @"PBRuntimeSixController"
            },
            @{
                @"title": @"方法添加",
                @"vc": @"PBRuntimeSevenController"
            },
            @{
                @"title": @"属性添加",
                @"vc": @"PBRuntimeEightController"
            }
        ];
    }
    return _objs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"【%ld】%@", indexPath.row, self.objs[indexPath.row][@"title"]];
    cell.detailTextLabel.text = self.objs[indexPath.row][@"vc"];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.textColor = [UIColor blueColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Class aClass = NSClassFromString(self.objs[indexPath.row][@"vc"]);
    UIViewController *testListController = [[aClass alloc]init];
    
    [self.navigationController pushViewController:testListController animated:YES];
    testListController.view.backgroundColor = [UIColor whiteColor];
}

@end
