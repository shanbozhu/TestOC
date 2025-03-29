//
//  PBHouseController.m
//  TestOC
//
//  Created by zhushanbo on 2025/3/27.
//  Copyright © 2025 DaMaiIOS. All rights reserved.
//

#import "PBHouseController.h"
#import <YYText/YYText.h>
#import "PBHouse.h"
#import "PBHouseCell.h"

@interface PBHouseController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation PBHouseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100; // required
    self.tableView.showsVerticalScrollIndicator = NO;
    
    NSDictionary *originalData = @{
        @"theFirstPayment" : @35, // 首付 + 契税
        @"totalMortgage" : @47, // 总房贷
        @"remainingMortgage" : @44, // 剩余房贷
        @"accumulatedRepaymentOfHousingLoans" : @13, // 已还房贷累计
        @"sell" : @50, // 出售
        @"buyAgain" : @50 // 重新购买
    };
    PBHouse *house = [PBHouse yy_modelWithDictionary:originalData];
    NSLog(@"house.theFirstPayment = %ld", house.theFirstPayment);
    
    NSMutableArray *data = [NSMutableArray array];
    self.data = data;
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"首付";
        showData.content = [NSString stringWithFormat:@"%ld", house.theFirstPayment];
        showData.isHighlight = YES;
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"总房贷";
        showData.content = [NSString stringWithFormat:@"%ld", house.totalMortgage];
        showData.isHighlight = YES;
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"开始总成本";
        showData.content = [NSString stringWithFormat:@"%ld + %ld = %ld", house.theFirstPayment, house.totalMortgage, house.theFirstPayment + house.totalMortgage];
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"剩余房贷";
        showData.content = [NSString stringWithFormat:@"%ld", house.remainingMortgage];
        showData.isHighlight = YES;
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"已还房贷累计";
        showData.content = [NSString stringWithFormat:@"%ld", house.accumulatedRepaymentOfHousingLoans];
        showData.isHighlight = YES;
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"实际已经支出";
        showData.content = [NSString stringWithFormat:@"%ld + %ld = %ld", house.theFirstPayment, house.accumulatedRepaymentOfHousingLoans, house.theFirstPayment + house.accumulatedRepaymentOfHousingLoans];
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"已还本金";
        showData.content = [NSString stringWithFormat:@"%ld - %ld = %ld", house.totalMortgage, house.remainingMortgage, house.totalMortgage - house.remainingMortgage];
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"已还利息";
        showData.content = [NSString stringWithFormat:@"%ld - %ld = %ld", house.accumulatedRepaymentOfHousingLoans, house.totalMortgage - house.remainingMortgage, house.accumulatedRepaymentOfHousingLoans - (house.totalMortgage - house.remainingMortgage)];
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"目前总成本";
        showData.content = [NSString stringWithFormat:@"%ld + %ld + %ld = %ld", house.theFirstPayment, house.accumulatedRepaymentOfHousingLoans, house.remainingMortgage, house.theFirstPayment + house.accumulatedRepaymentOfHousingLoans + house.remainingMortgage];
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"或者";
        showData.content = @"";
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"已还利息";
        showData.content = [NSString stringWithFormat:@"%ld - %ld = %ld", house.theFirstPayment + house.accumulatedRepaymentOfHousingLoans + house.remainingMortgage, house.theFirstPayment + house.totalMortgage, (house.theFirstPayment + house.accumulatedRepaymentOfHousingLoans + house.remainingMortgage) - (house.theFirstPayment + house.totalMortgage)];
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"出售";
        showData.content = [NSString stringWithFormat:@"假如卖%ld，首先还完房贷%ld，到手还剩%ld", house.sell, house.remainingMortgage, house.sell - house.remainingMortgage];
        showData.isHighlight = YES;
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"整体亏损";
        showData.content = [NSString stringWithFormat:@"%ld + %ld - %ld = %ld", house.theFirstPayment, house.accumulatedRepaymentOfHousingLoans, house.sell - house.remainingMortgage, house.theFirstPayment + house.accumulatedRepaymentOfHousingLoans - (house.sell - house.remainingMortgage)];
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"或者";
        showData.content = @"";
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"整体亏损";
        showData.content = [NSString stringWithFormat:@"%ld - %ld = %ld", house.theFirstPayment + house.accumulatedRepaymentOfHousingLoans + house.remainingMortgage, house.sell, house.theFirstPayment + house.accumulatedRepaymentOfHousingLoans + house.remainingMortgage - house.sell];
        [data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"购买";
        showData.content = [NSString stringWithFormat:@"假如想重新买套价值%ld的房，按三成来算，首付%ld * 0.3 = %.lf，还需要额外拿出%.lf - %ld = %.lf，重新贷款%ld - %.lf = %.lf", house.buyAgain, house.buyAgain, house.buyAgain * 0.3, house.buyAgain * 0.3, house.sell - house.remainingMortgage, house.buyAgain * 0.3 - (house.sell - house.remainingMortgage), house.sell, house.buyAgain * 0.3, house.sell - house.buyAgain * 0.3];
        showData.isHighlight = YES;
        [data addObject:showData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBHouseCell *cell = [PBHouseCell houseCellWithTableView:tableView];
    cell.showData = self.data[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
