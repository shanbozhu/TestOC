//
//  PBTestListTwoView.m
//  TestBundle
//
//  Created by Zhu,Shanbo on 2019/6/26.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBTestListTwoView.h"
#import "PBTestListTwoCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface PBTestListTwoView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

+ (id)testListTwoView;

@end

@implementation PBTestListTwoView

+ (id)testListTwoView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // tableView
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        self.tableView = tableView;
        [self addSubview:tableView];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.tableFooterView = [UIView new];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
    }
    return self;
}

- (void)setTestTwoEspressos:(PBTestTwoEspressos *)testTwoEspressos {
    _testTwoEspressos = testTwoEspressos;
    if (testTwoEspressos) {
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        PBTestListTwoCell *cell = [PBTestListTwoCell testListTwoCellWithTableView:tableView];
        cell.testTwoEspressos = self.testTwoEspressos;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        }
        cell.textLabel.text = @"UITableViewCell";
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        if ([self.testTwoEspressos height] == 0) {
            [tableView registerClass:[PBTestListTwoCell class] forCellReuseIdentifier:@"PBTestListTwoCell"];
            [self.testTwoEspressos setHeight:[tableView fd_heightForCellWithIdentifier:@"PBTestListTwoCell" configuration:^(id cell) {
                PBTestListTwoCell *testListTwoCell = cell;
                testListTwoCell.fd_enforceFrameLayout = YES;
                
                self.testTwoEspressos.tableView = tableView; // 算高时需要使用
                testListTwoCell.testTwoEspressos = self.testTwoEspressos;
            }]];
        }
        NSLog(@"2222 = %lf", [self.testTwoEspressos height]);
        return [self.testTwoEspressos height];
    } else if (indexPath.row == 0) {
        return 80;
    } else if (indexPath.row == 1) {
        return 100;
    } else {
        return 1000;
    }
}

@end
