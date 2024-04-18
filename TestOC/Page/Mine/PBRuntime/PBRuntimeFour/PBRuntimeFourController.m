//
//  PBRuntimeFourController.m
//  TestOC
//
//  Created by shanbo on 2024/4/18.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeFourController.h"
#import "PBMethodSwizzling.h"
#include <execinfo.h> /* for backtrace() */

@interface PBRuntimeFourController ()

@end

@implementation PBRuntimeFourController

#pragma mark -

+ (void)load {
    Class aClass = NSClassFromString(@"UIDevice");
    if (aClass) {
        [PBMethodSwizzling replaceClass:[aClass class]
                                    sel:@selector(systemVersion)
                              withClass:[self class]
                                withSEL:@selector(debug_systemVersion)
                          isClassMethod:NO];
    }
}

- (NSString *)debug_systemVersion {
    NSLog(@"<<<<%@>>>>", [PBRuntimeFourController getSymbolsWithDepth:1000]);
    return [self debug_systemVersion];
}

+ (NSString *)getSymbolsWithDepth:(int)size {
    vm_address_t *stacks[size];
    size_t depth = backtrace((void**)stacks, size);
    NSMutableString *stackInfo = [[NSMutableString alloc] init];
    NSDateFormatter* df1 = [NSDateFormatter new];
    df1.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSString *dateStr1 = [df1 stringFromDate:[NSDate date]];
    [stackInfo appendFormat:@"%@\n", dateStr1];
    
    char **strings;
    strings = backtrace_symbols((void**)stacks, (int)depth);
    if (strings == NULL) {
        return NULL;
    }
    for (int j = 0; j < depth; j++) {
        NSString *str=  [[NSString alloc] initWithUTF8String:strings[j]];
        [stackInfo appendFormat:@"%@\n", str];
    }
    free(strings);
    
    return stackInfo;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"[UIDevice currentDevice].systemVersion = %@", [UIDevice currentDevice].systemVersion);
}


@end
