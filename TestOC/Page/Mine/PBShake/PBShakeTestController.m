//
//  PBShakeTestController.m
//  TestOC
//
//  Created by zhushanbo on 2026/11/2.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBShakeTestController.h"

@interface PBShakeTestController ()

@property (nonatomic, strong) NSArray *objs;

@end

@implementation PBShakeTestController

- (NSArray *)objs {
    if (!_objs) {
        _objs = @[
            @{
                @"title": @"加速度计/陀螺仪",
                @"vc": @"PBShakeController"
            },
            @{
                @"title": @"DeviceMotion 动作识别",
                @"vc": @"PBShakeTwoController"
            },
            @{
                @"title": @"电子罗盘方向摇一摇",
                @"vc": @"PBShakeThreeController"
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
