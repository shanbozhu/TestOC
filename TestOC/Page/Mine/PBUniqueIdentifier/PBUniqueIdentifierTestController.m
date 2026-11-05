//
//  PBUniqueIdentifierTestController.m
//  TestOC
//
//  Created by zhushanbo on 2026/11/2.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBUniqueIdentifierTestController.h"

@interface PBUniqueIdentifierTestController ()

@property (nonatomic, strong) NSArray *objs;

@end

@implementation PBUniqueIdentifierTestController

- (NSArray *)objs {
    if (!_objs) {
        _objs = @[
            @{
                @"title": @"常见设备标识方案对比",
                @"vc": @"PBUniqueIdentifierController"
            },
            @{
                @"title": @"应用内持久身份",
                @"vc": @"PBUniqueDeviceIdentifierController"
            },
            @{
                @"title": @"跨 App 身份与归因",
                @"vc": @"PBCrossAppUniqueDeviceIdentifierController"
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
    testListController.title = self.objs[indexPath.row][@"vc"];

    [self.navigationController pushViewController:testListController animated:YES];
    testListController.view.backgroundColor = [UIColor whiteColor];
}

@end
