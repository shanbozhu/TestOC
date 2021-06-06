//
//  PBSyntaxController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/13.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBSyntaxController.h"
#import "PBSyntax.h"

@interface PBSyntaxController ()

@end

@implementation PBSyntaxController

- (void)viewDidLoad {
    [super viewDidLoad];

    PBSyntax *syntax = [[PBSyntax alloc] init];
    NSLog(@"syntax.height = %@", syntax.height);
    
    // class property
    PBSyntax.someString = @"class property";
    NSLog(@"PBSyntax.someString = %@", PBSyntax.someString);
}



@end
