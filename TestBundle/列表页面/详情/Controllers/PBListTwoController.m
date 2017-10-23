//
//  PBListTwoController.m
//  PBHome
//
//  Created by DaMaiIOS on 17/10/8.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBListTwoController.h"

@interface PBListTwoController ()

@end

@implementation PBListTwoController

//-(BOOL)pb_panGestureRecognizerEnabled {
//    return NO;
//}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //self.navigationItem.hidesBackButton = YES;
    //self.tabBarController.navigationItem.title = @"lala";
    self.navigationItem.title = @"lala";
}



@end
