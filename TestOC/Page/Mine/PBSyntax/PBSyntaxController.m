//
//  PBSyntaxController.m
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/4/13.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

#import "PBSyntaxController.h"
#import "PBSyntax.h"
#import "PBSyntaxSome.h"

#define TestMacro @"PBSyntaxController"

@interface PBSyntaxController ()

@end

@implementation PBSyntaxController

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)setupUI {
    NSLog(@"调用PBSyntaxController的setupUI");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PBSyntax *syntax = [[PBSyntax alloc] init];
    
#pragma mark - interface
    
    // property
    syntax.age = @"18";
    NSLog(@"syntax.age = %@", syntax.age);
    
    // class property
    PBSyntax.someString = @"class property";
    NSLog(@"PBSyntax.someString = %@", PBSyntax.someString);
    PBSyntax.someCls = [PBSyntaxSome class];
    NSLog(@"PBSyntax.someCls = %@", PBSyntax.someCls);
    
#pragma mark - protocol
    
    syntax.name = @"bobo";
    NSLog(@"syntax.name = %@", syntax.name);
    NSLog(@"[syntax sex] = %@", [syntax sex]);
    NSLog(@"[PBSyntax.someCls func] = %@", [PBSyntax.someCls fn]);
    
    // 如果不显式遵守protocol，那么调用conformsToProtocol方法将返回NO
    PBSyntaxSome *syntaxSome = [[PBSyntaxSome alloc] init];
    NSLog(@"[syntaxSome conformsToProtocol:@protocol(PBSyntaxProtocol)] = %d", [syntaxSome conformsToProtocol:@protocol(PBSyntaxProtocol)]);
    NSLog(@"[PBSyntaxSome conformsToProtocol:@protocol(PBSyntaxProtocol)] = %d", [PBSyntaxSome conformsToProtocol:@protocol(PBSyntaxProtocol)]);
    
#pragma mark - extension
    
    syntax.weight = @"120";
    NSLog(@"syntax.weight = %@", syntax.weight);
    NSLog(@"[syntax hobby] = %@", [syntax hobby]);
    
#pragma mark - category
    
    syntax.sing = @"sing";
    NSLog(@"syntax.sing = %@", syntax.sing);
    
#pragma mark - Macro
    
    // TestMacro
    NSLog(@"TestMacro = %@", TestMacro);
}

@end
