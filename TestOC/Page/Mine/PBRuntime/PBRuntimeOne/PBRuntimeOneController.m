//
//  PBRuntimeOneController.m
//  TestOC
//
//  Created by shanbo on 2023/3/20.
//  Copyright © 2023 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeOneController.h"

#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>

@interface PBRuntimeOneController ()

@end

@implementation PBRuntimeOneController

+ (NSArray <Class> *)pb_bundleOwnClassesInfo {
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    unsigned int classCount;
    const char **classes;
    Dl_info info;
    
    dladdr(&_mh_execute_header, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &classCount);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString *className = [NSString stringWithCString:classes[index] encoding:NSUTF8StringEncoding];
        Class class = NSClassFromString(className);
        [resultArray addObject:class];
        dispatch_semaphore_signal(semaphore);
    });
    
    return resultArray.mutableCopy;
}

+ (NSArray <NSString *> *)pb_bundleAllClassesInfo {
    
    NSMutableArray *resultArray = [NSMutableArray new];

    int classCount = objc_getClassList(NULL, 0);

    Class *classes = NULL;
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) *classCount);
    classCount = objc_getClassList(classes, classCount);

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        Class class = classes[index];
        NSString *className = [[NSString alloc] initWithUTF8String: class_getName(class)];
        [resultArray addObject:className];
        dispatch_semaphore_signal(semaphore);
    });

    free(classes);
    
    return resultArray.mutableCopy;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"[self pb_bundleOwnClassesInfo] = %@", [self.class pb_bundleOwnClassesInfo]);
    NSLog(@"[self pb_bundleAllClassesInfo] = %@", [self.class pb_bundleAllClassesInfo]);
}



@end
