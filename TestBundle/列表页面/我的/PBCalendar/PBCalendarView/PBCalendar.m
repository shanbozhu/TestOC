//
//  PBCalendar.m
//  TestBundle
//
//  Created by DaMaiIOS on 2018/4/20.
//  Copyright © 2018年 DaMaiIOS. All rights reserved.
//

#import "PBCalendar.h"

@interface PBCalendar ()

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, strong) NSMutableArray *dayArr;

@end

@implementation PBCalendar

- (id)init {
    if (self = [super init]) {
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.calendar = calendar;
        NSDateComponents *nowComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        self.year = nowComponents.year;
        self.month = nowComponents.month;
        self.day = nowComponents.day;
        
        self.dayArr = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)setDayArr {
    // 现在日期(年-月-日)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *nowDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%d", self.year, self.month, 01]];
    
    // 本月的天数范围
    NSRange dayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:nowDate];
    
    // 上月的天数范围
    NSRange lastDayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self setLastMonthWithDay]];
    
    // 本月第一天的NSDate对象
    NSDate *nowMonthFirst = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%d", self.year, self.month, 01]];
    // 本月第一天是星期几
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:nowMonthFirst];
    // 本月最后一天的NSDate对象
    NSDate *nextDay = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld", self.year, self.month, dayRange.length]];
    NSDateComponents *lastDay = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:nextDay];
    
    // 上个月遗留的天数
    for (NSInteger i = lastDayRange.length-components.weekday+2; i <= lastDayRange.length; i++) {
        NSString *string = [NSString stringWithFormat:@"%ld", i];
        [self.dayArr addObject:string];
    }
    
    // 本月的总天数
    for (NSInteger i = 1; i <= dayRange.length; i++) {
        NSString *string = [NSString stringWithFormat:@"%ld", i];
        [self.dayArr addObject:string];
    }
    
    // 下个月空出的天数
    for (NSInteger i = 1; i <= (7-lastDay.weekday); i++) {
        NSString *string = [NSString stringWithFormat:@"%ld", i];
        [self.dayArr addObject:string];
    }
    
    // 今天的日期所在索引
    self.index = components.weekday - 2 + self.day;
    
    self.dateBlock(self.year, self.month);
    
    return self.dayArr;
}

// 返回上个月第一天的NSDate对象
- (NSDate *)setLastMonthWithDay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = nil;
    if (self.month != 1) {
        date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%d", self.year, self.month-1, 01]];
    } else {
        date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%d-%d", self.year-1, 12, 01]];
    }
    return date;
}

- (NSArray *)nextMonthDataArr {
    [self.dayArr removeAllObjects];
    if (self.month == 12) {
        self.month = 1;
        self.year++;
    } else {
        self.month++;
    }
    return [self setDayArr];
}

- (NSArray *)lastMonthDataArr {
    [self.dayArr removeAllObjects];
    if (self.month == 1) {
        self.month = 12;
        self.year--;
    } else {
        self.month--;
    }
    return [self setDayArr];
}

@end
