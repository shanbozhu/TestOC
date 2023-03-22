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
    
    PBCalendarView *calendarView = [PBCalendarView calendarViewWithFrame:CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - APPLICATION_NAVIGATIONBAR_HEIGHT)];
    [self.view addSubview:calendarView];
}

@end
