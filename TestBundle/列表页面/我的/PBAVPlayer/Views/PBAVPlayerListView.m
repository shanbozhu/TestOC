//
//  PBAVPlayerListView.m
//  TestBundle
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAVPlayerListView.h"
#import "PBAVPlayerListCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface PBAVPlayerListView ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PBAVPlayerListView

+ (id)testListView {
    return [[[NSBundle mainBundle]loadNibNamed:@"PBAVPlayerListView" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setTestEspressosArr:(NSArray *)testEspressosArr {
    _testEspressosArr = testEspressosArr;
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testEspressosArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBAVPlayerListCell *cell = [PBAVPlayerListCell testListCellWithTableView:tableView andReuseIdentifier:@"PBAVPlayerListCell"];
    
    cell.testEspressos = self.testEspressosArr[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
}

@end
