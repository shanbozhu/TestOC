//
//  PBRuntimeEightController+Debug.m
//  TestOC
//
//  Created by shanbo on 2024/4/25.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeEightController+Debug.h"

@implementation PBRuntimeEightController (Debug)

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"key = %@", key);
    if ([key isEqualToString:@"aa"]) {
        objc_setAssociatedObject(self, @selector(aa), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"key = %@", key);
    if ([key isEqualToString:@"aa"]) {
        return objc_getAssociatedObject(self, @selector(aa));
    }
    return self;
}

#pragma mark - 对象类型

- (NSString *)name {
    return objc_getAssociatedObject(self, @selector(name));
}

- (void)setName:(NSString *)name {
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 基本类型

- (NSInteger)age {
    return [objc_getAssociatedObject(self, @selector(age)) integerValue];
}

- (void)setAge:(NSInteger)age {
    objc_setAssociatedObject(self, @selector(age), @(age), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
