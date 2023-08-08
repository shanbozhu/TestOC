//
//  PBAttributedStringController.m
//  TestOC
//
//  Created by shanbo on 2023/7/13.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBAttributedStringController.h"
#import "PBYYTextCell.h"

@interface PBAttributedStringController ()

@end

@implementation PBAttributedStringController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *str = [PBYYTextCell originStr];
    NSLog(@"str = %@", str);
}



@end
