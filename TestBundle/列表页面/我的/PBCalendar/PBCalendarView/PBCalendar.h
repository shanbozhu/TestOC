//
//  PBCalendar.h
//  TestBundle
//
//  Created by DaMaiIOS on 2018/4/20.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBCalendar : NSObject

@property (nonatomic, strong) void(^dateBlock)(NSInteger year, NSInteger month);

@property (nonatomic, assign) NSInteger index;

- (NSArray *)setDayArr;
- (NSArray *)nextMonthDataArr;
- (NSArray *)lastMonthDataArr;

@end
