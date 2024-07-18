//
//  PBRuntimeSevenDebugController.m
//  TestOC
//
//  Created by shanbo on 2024/4/23.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeSevenDebugController.h"

@interface PBRuntimeSevenDebugController ()

@end

@implementation PBRuntimeSevenDebugController

+ (void)load {
    /**
     Method：方法(函数)，包含selector(函数名，也可以表示为_cmd)和IMP(函数体)
     selector：函数名
     IMP：函数体
     */
    {
        // 方案一
        IMP imp = class_getMethodImplementation(NSClassFromString(@"PBRuntimeSevenDebugController"), @selector(run:a:)); // 获取对象方法的IMP
        class_addMethod(NSClassFromString(@"PBRuntimeSevenController"), @selector(run:a:), imp, "v@:@@");
    }
    
    {
        // 方案二
        Method method = class_getInstanceMethod(NSClassFromString(@"PBRuntimeSevenDebugController"), @selector(func:));
        IMP imp = method_getImplementation(method); // 既可以获取对象方法的IMP，也可以获取类方法的IMP
        class_addMethod(NSClassFromString(@"PBRuntimeSevenController"), @selector(func:), imp, method_getTypeEncoding(method));
    }
    
    {
        // 方案三
        
        // 添加C方法
        class_addMethod(NSClassFromString(@"PBRuntimeSevenController"), @selector(c_run), (IMP)c_run, "v@:@");
    }
}

- (void)run:(NSString *)name a:(NSNumber *)a {
    NSLog(@"----run----, name = %@, a = %@", name, a);
}

- (void)func:(NSString *)name {
    NSLog(@"----func----, name = %@", name);
}

// C方法
void c_run(id self, SEL _cmd, NSString *name) {
    NSLog(@"self = %@, _cmd = %s, name = %@", self, sel_getName(_cmd), name);
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
