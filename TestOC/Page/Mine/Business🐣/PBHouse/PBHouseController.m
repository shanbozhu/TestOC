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

#define kTheFirstPayment @"theFirstPayment"
#define kTotalMortgage @"totalMortgage"
#define kRemainingMortgage @"remainingMortgage"
#define kAccumulatedRepaymentOfHousingLoans @"accumulatedRepaymentOfHousingLoans"
#define kSell @"sell"
#define kBuyAgain @"buyAgain"

@interface PBHouseController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary *originalData;
@property (nonatomic, strong) PBHouse *house;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation PBHouseController

- (NSDictionary *)originalData {
    return @{
        kTheFirstPayment : @35, // 首付 + 契税
        kTotalMortgage : @47, // 总房贷
        kRemainingMortgage : @44, // 剩余房贷
        kAccumulatedRepaymentOfHousingLoans : @13, // 已还房贷累计
        kSell : @50, // 出售
        kBuyAgain : @50 // 重新购买
    };
}

- (void)setupData {
    [self setupOriginalData];
    [self setupShowData];
}

- (void)setupOriginalData {
    self.house = [PBHouse yy_modelWithDictionary:self.originalData];
    NSLog(@"self.house.theFirstPayment = %ld", self.house.theFirstPayment);
}

- (void)setupShowData {
    self.data = nil;
    self.data = [NSMutableArray array];
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"首付";
        showData.content = [NSString stringWithFormat:@"%ld", self.house.theFirstPayment];
        showData.isHighlight = YES;
        showData.key = kTheFirstPayment;
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"总房贷";
        showData.content = [NSString stringWithFormat:@"%ld", self.house.totalMortgage];
        showData.isHighlight = YES;
        showData.key = kTotalMortgage;
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"开始总成本";
        showData.content = [NSString stringWithFormat:@"%ld + %ld = %ld", self.house.theFirstPayment, self.house.totalMortgage, self.house.theFirstPayment + self.house.totalMortgage];
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"剩余房贷";
        showData.content = [NSString stringWithFormat:@"%ld", self.house.remainingMortgage];
        showData.isHighlight = YES;
        showData.key = kRemainingMortgage;
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"已还房贷累计";
        showData.content = [NSString stringWithFormat:@"%ld", self.house.accumulatedRepaymentOfHousingLoans];
        showData.isHighlight = YES;
        showData.key = kAccumulatedRepaymentOfHousingLoans;
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"实际已经支出";
        showData.content = [NSString stringWithFormat:@"%ld + %ld = %ld", self.house.theFirstPayment, self.house.accumulatedRepaymentOfHousingLoans, self.house.theFirstPayment + self.house.accumulatedRepaymentOfHousingLoans];
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"已还本金";
        showData.content = [NSString stringWithFormat:@"%ld - %ld = %ld", self.house.totalMortgage, self.house.remainingMortgage, self.house.totalMortgage - self.house.remainingMortgage];
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"已还利息";
        showData.content = [NSString stringWithFormat:@"%ld - %ld = %ld", self.house.accumulatedRepaymentOfHousingLoans, self.house.totalMortgage - self.house.remainingMortgage, self.house.accumulatedRepaymentOfHousingLoans - (self.house.totalMortgage - self.house.remainingMortgage)];
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"目前总成本";
        showData.content = [NSString stringWithFormat:@"%ld + %ld + %ld = %ld", self.house.theFirstPayment, self.house.accumulatedRepaymentOfHousingLoans, self.house.remainingMortgage, self.house.theFirstPayment + self.house.accumulatedRepaymentOfHousingLoans + self.house.remainingMortgage];
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"或者";
        showData.content = @"";
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"已还利息";
        showData.content = [NSString stringWithFormat:@"%ld - %ld = %ld", self.house.theFirstPayment + self.house.accumulatedRepaymentOfHousingLoans + self.house.remainingMortgage, self.house.theFirstPayment + self.house.totalMortgage, (self.house.theFirstPayment + self.house.accumulatedRepaymentOfHousingLoans + self.house.remainingMortgage) - (self.house.theFirstPayment + self.house.totalMortgage)];
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"出售";
        showData.content = [NSString stringWithFormat:@"假如卖%ld，首先还完房贷%ld，到手还剩%ld", self.house.sell, self.house.remainingMortgage, self.house.sell - self.house.remainingMortgage];
        showData.isHighlight = YES;
        showData.key = kSell;
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"整体亏损";
        showData.content = [NSString stringWithFormat:@"%ld + %ld - %ld = %ld", self.house.theFirstPayment, self.house.accumulatedRepaymentOfHousingLoans, self.house.sell - self.house.remainingMortgage, self.house.theFirstPayment + self.house.accumulatedRepaymentOfHousingLoans - (self.house.sell - self.house.remainingMortgage)];
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"或者";
        showData.content = @"";
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"整体亏损";
        showData.content = [NSString stringWithFormat:@"%ld - %ld = %ld", self.house.theFirstPayment + self.house.accumulatedRepaymentOfHousingLoans + self.house.remainingMortgage, self.house.sell, self.house.theFirstPayment + self.house.accumulatedRepaymentOfHousingLoans + self.house.remainingMortgage - self.house.sell];
        [self.data addObject:showData];
    }
    {
        PBHouseShowData *showData = [[PBHouseShowData alloc] init];
        showData.title = @"重新购买";
        showData.content = [NSString stringWithFormat:@"假如想重新买套价值%ld的房，按三成来算，首付%ld * 0.3 = %.lf，还需要额外拿出%.lf - %ld = %.lf，重新贷款%ld - %.lf = %.lf", self.house.buyAgain, self.house.buyAgain, self.house.buyAgain * 0.3, self.house.buyAgain * 0.3, self.house.sell - self.house.remainingMortgage, self.house.buyAgain * 0.3 - (self.house.sell - self.house.remainingMortgage), self.house.sell, self.house.buyAgain * 0.3, self.house.sell - self.house.buyAgain * 0.3];
        showData.isHighlight = YES;
        showData.key = kBuyAgain;
        [self.data addObject:showData];
    }
    
    // 刷新UI
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100; // required
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self setupData];
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
    PBHouseShowData *showData = self.data[indexPath.row];
    if ([showData.key isEqualToString:kTheFirstPayment]) {
        [self debugNovelCoreSelectTitleChannel:showData title:showData.key];
    } else if ([showData.key isEqualToString:kTotalMortgage]) {
        [self debugNovelCoreSelectTitleChannel:showData title:showData.key];
    } else if ([showData.key isEqualToString:kRemainingMortgage]) {
        [self debugNovelCoreSelectTitleChannel:showData title:showData.key];
    } else if ([showData.key isEqualToString:kAccumulatedRepaymentOfHousingLoans]) {
        [self debugNovelCoreSelectTitleChannel:showData title:showData.key];
    } else if ([showData.key isEqualToString:kSell]) {
        [self debugNovelCoreSelectTitleChannel:showData title:showData.key];
    } else if ([showData.key isEqualToString:kBuyAgain]) {
        [self debugNovelCoreSelectTitleChannel:showData title:showData.key];
    }
}

- (void)debugNovelCoreSelectTitleChannel:(PBHouseShowData *)showData title:(NSString *)title {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = [NSString stringWithFormat:@"请输入数字，单位默认是万"];
    }];
    UIAlertAction *alertText = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [[alertView textFields] firstObject];
        NSLog(@"textField.text = %@", textField.text);
        if ([showData.key isEqualToString:kTheFirstPayment]) {
            self.house.theFirstPayment = [textField.text integerValue];
        } else if ([showData.key isEqualToString:kTotalMortgage]) {
            self.house.totalMortgage = [textField.text integerValue];
        } else if ([showData.key isEqualToString:kRemainingMortgage]) {
            self.house.remainingMortgage = [textField.text integerValue];
        } else if ([showData.key isEqualToString:kAccumulatedRepaymentOfHousingLoans]) {
            self.house.accumulatedRepaymentOfHousingLoans = [textField.text integerValue];
        } else if ([showData.key isEqualToString:kSell]) {
            self.house.sell = [textField.text integerValue];
        } else if ([showData.key isEqualToString:kBuyAgain]) {
            self.house.buyAgain = [textField.text integerValue];
        }
        // 刷新UI
        [self setupShowData];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:cancleAction];
    [alertView addAction:alertText];
    [self presentViewController:alertView animated:YES completion:nil];
}

@end
