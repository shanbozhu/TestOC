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

// 参考文档：
// iOS遍历打印所有子视图 https://www.jianshu.com/p/f78a82bdfc68
// iOS 遍历所有子视图subviews的2种方法 https://www.cnblogs.com/allanliu/p/4229762.html

+ (void)logViewHierarchy:(UIView *)view outer:(BOOL)outer {
    for (UIView *subview in view.subviews) {
        // 层级
        static NSInteger i = 0;
        if (outer) {
            i = 0;
        }
        i++;
        if (subview.superview.tag > 0) {
            i = subview.superview.tag;
        }
        subview.superview.tag = i;
        
        // 打印
        NSString *blank = @"";
        for (int j = 1; j < i; j++) {
            blank = [blank stringByAppendingString:@"  "];
        }
        NSLog(@"%@%ld: %@", blank, i, subview.class);
        
        [self logViewHierarchy:subview outer:NO];
    }
}

+ (void)logViewHierarchy:(UIView *)view level:(int)level {
    for (UIView *subview in view.subviews) {
        // 打印
        NSString *blank = @"";
        for (int i = 1; i < level; i++) {
            blank = [blank stringByAppendingString:@"  "];
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
    
    UIView *oneView2 = [[UIView alloc] init];
    [oneView addSubview:oneView2];
    
    //
    UILabel *twoLab = [[UILabel alloc] init];
    [self.view addSubview:twoLab];
    
    {
        [self.class logViewHierarchy:self.view outer:YES];
    }
    
    {
        [self.class logViewHierarchy:self.view level:1];
    }
}

@end
