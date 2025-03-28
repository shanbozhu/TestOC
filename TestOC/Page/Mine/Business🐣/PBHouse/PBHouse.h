//
//  PBHouse.h
//  TestOC
//
//  Created by zhushanbo on 2025/3/28.
//  Copyright © 2025 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBHouseShowData : NSObject <YYModel>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL isHighlight;

@end

@interface PBHouse : NSObject <YYModel>

@property (nonatomic, assign) NSInteger theFirstPayment;
@property (nonatomic, assign) NSInteger totalMortgage;
@property (nonatomic, assign) NSInteger remainingMortgage;
@property (nonatomic, assign) NSInteger accumulatedRepaymentOfHousingLoans;
@property (nonatomic, assign) NSInteger sell;
@property (nonatomic, assign) NSInteger buyAgain;

@end

NS_ASSUME_NONNULL_END
