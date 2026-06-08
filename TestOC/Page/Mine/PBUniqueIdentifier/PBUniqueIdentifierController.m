//
//  PBUniqueIdentifierController.m
//  TestOC
//
//  Created by zhushanbo on 2026/6/8.
//  Copyright © 2026 DaMaiIOS. All rights reserved.
//

#import "PBUniqueIdentifierController.h"
#import "PBUniqueIdentifierHelper.h"
#import "PBDeviceCheckExampleController.h"

@interface PBUniqueIdentifierController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray<PBUniqueIdentifierItem *> *items;
@property (nonatomic, assign) BOOL isRefreshing;

@end

@implementation PBUniqueIdentifierController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.items = [PBUniqueIdentifierHelper allSchemeItems];
    
    [self setupNavigationItems];
    [self setupTableView];
    [self refreshAllIdentifiers];
}

#pragma mark - UI

- (void)setupNavigationItems {
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(refreshAllIdentifiers)],
        [[UIBarButtonItem alloc] initWithTitle:@"请求 IDFA 授权"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(requestIDFAAuthorization)],
    ];
}

- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 120;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedSectionHeaderHeight = 44;
    tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"PBUniqueIdentifierHeader"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - Actions

- (void)refreshAllIdentifiers {
    if (self.isRefreshing) {
        return;
    }
    self.isRefreshing = YES;
    
    for (PBUniqueIdentifierItem *item in self.items) {
        item.identifierValue = @"加载中...";
    }
    [self.tableView reloadData];
    
    [PBUniqueIdentifierHelper refreshAllIdentifiersForItems:self.items completion:^{
        self.isRefreshing = NO;
        [self.tableView reloadData];
    }];
}

- (void)requestIDFAAuthorization {
    [PBUniqueIdentifierHelper requestIDFAAuthorizationWithCompletion:^{
        PBUniqueIdentifierItem *idfaItem = [self itemForSchemeType:PBUniqueIdentifierSchemeTypeIDFA];
        if (!idfaItem) {
            return;
        }
        [PBUniqueIdentifierHelper refreshIdentifierForItem:idfaItem completion:^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:PBUniqueIdentifierSchemeTypeIDFA inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
}

- (PBUniqueIdentifierItem *)itemForSchemeType:(PBUniqueIdentifierSchemeType)schemeType {
    for (PBUniqueIdentifierItem *item in self.items) {
        if (item.schemeType == schemeType) {
            return item;
        }
    }
    return nil;
}

- (void)copyIdentifierAtIndexPath:(NSIndexPath *)indexPath {
    PBUniqueIdentifierItem *item = self.items[indexPath.row];
    if (item.identifierValue.length == 0 ||
        [item.identifierValue isEqualToString:@"加载中..."]) {
        return;
    }
    
    [UIPasteboard generalPasteboard].string = item.identifierValue;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已复制"
                                                                   message:item.name
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const cellID = @"PBUniqueIdentifierCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    PBUniqueIdentifierItem *item = self.items[indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [item summaryText];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PBUniqueIdentifierItem *item = self.items[indexPath.row];
    if (item.schemeType == PBUniqueIdentifierSchemeTypeDeviceCheck) {
        PBDeviceCheckExampleController *vc = [[PBDeviceCheckExampleController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    [self copyIdentifierAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"PBUniqueIdentifierHeader"];
    
    UILabel *label = [header.contentView viewWithTag:100];
    if (!label) {
        label = [[UILabel alloc] init];
        label.tag = 100;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor darkGrayColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [header.contentView addSubview:label];
        [NSLayoutConstraint activateConstraints:@[
            [label.topAnchor constraintEqualToAnchor:header.contentView.topAnchor constant:8],
            [label.leadingAnchor constraintEqualToAnchor:header.contentView.leadingAnchor constant:16],
            [label.trailingAnchor constraintEqualToAnchor:header.contentView.trailingAnchor constant:-16],
            [label.bottomAnchor constraintEqualToAnchor:header.contentView.bottomAnchor constant:-8],
        ]];
    }
    label.text = @"点击行可复制标识值；DeviceCheck 行可进入工作流示例；IDFA 需先点右上角「请求 IDFA 授权」";
    return header;
}

@end
