//
//  PBCalendarController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2019/7/23.
//  Copyright © 2019年 DaMaiIOS. All rights reserved.
//

#import "PBCalendarController.h"
#import "PBCalendarView.h"

@interface PBCalendarController ()

@end

@implementation PBCalendarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PBCalendarView *calendarView = [PBCalendarView calendarViewWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    [self.view addSubview:calendarView];
}

@end
