//
//  PBRuntimeEightController.m
//  TestOC
//
//  Created by shanbo on 2024/4/25.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeEightController.h"
#import "PBRuntimeEightController+Debug.h"

@interface PBRuntimeEightController ()

@end

@implementation PBRuntimeEightController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        // 方案一
        
        // 分类中添加属性
        self.name = @"jack";
        self.age = 19;
        NSLog(@"self.name = %@, self.age = %ld", self.name, self.age);
    }
    
    {
        // 方案二
        [self performSelector:@selector(setHeight:) withObject:@[@"1", @"2", @{@"3" : @"4"}]];
        NSLog(@"height = %@", [self performSelector:@selector(height)]);
    }
}



@end
