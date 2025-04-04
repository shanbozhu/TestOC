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
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *key;

@end

@interface PBHouse : NSObject <YYModel>

@property (nonatomic, assign) CGFloat theFirstPayment;
@property (nonatomic, assign) CGFloat totalMortgage;
@property (nonatomic, assign) CGFloat remainingMortgage;
@property (nonatomic, assign) CGFloat accumulatedRepaymentOfHousingLoans;
@property (nonatomic, assign) CGFloat sell;
@property (nonatomic, assign) CGFloat buyAgain;

@end

NS_ASSUME_NONNULL_END
