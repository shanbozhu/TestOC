//
//  PBRuntimeThreeController.m
//  TestOC
//
//  Created by shanbo on 2024/4/18.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeThreeController.h"

@interface PBRuntimeThreeController ()

@end

@implementation PBRuntimeThreeController

#pragma mark -

// 参考文档:
// https://www.jianshu.com/p/f78a82bdfc68
// https://www.cnblogs.com/allanliu/p/4229762.html

+ (void)logViewHierarchy:(UIView *)view {
    for (UIView *subview in view.subviews) {
        static NSInteger i = 0;
        i++;
        if (subview.superview.tag > 0) {
            i = subview.superview.tag;
        }
        subview.superview.tag = i;
        
        if (i == 1) {
            NSLog(@"%ld: %@", i, subview.class);
        } else {
            NSLog(@"%*s%ld: %@", (int)i - 1, " ", i, subview.class);
        }
        
        [self logViewHierarchy:subview];
    }
}

+ (void)logViewHierarchy:(UIView *)view level:(int)level {
    for (UIView *subview in view.subviews) {
        // 根据层级决定前面空格个数，来缩进显示
        NSString *blank = @"";
        for (int i = 1; i < level; i++) {
            blank = [NSString stringWithFormat:@"  %@", blank];
        }
        
        NSLog(@"%@%d: %@", blank, level, subview.class);
        
        [self logViewHierarchy:subview level:level + 1];
    }
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    UILabel *oneLab = [[UILabel alloc] init];
    [self.view addSubview:oneLab];
    
    UIView *oneView = [[UIView alloc] init];
    [oneLab addSubview:oneView];
    
    //
    UILabel *twoLab = [[UILabel alloc] init];
    [self.view addSubview:twoLab];
    
    {
        [self.class logViewHierarchy:self.view];
    }
    
    {
        [self.class logViewHierarchy:self.view level:1];
    }
}

@end
