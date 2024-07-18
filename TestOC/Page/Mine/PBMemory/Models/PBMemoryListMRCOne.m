//
//  PBMemoryListMRCOne.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/29.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#ifdef OPENMRC
#import "PBMemoryListMRCOne.h"

@implementation PBMemoryListMRCOne

// 具有手动内存管理功能的getter和setter
- (NSString *)name {
    return _name;
}

- (void)setName:(NSString *)name {
    if (_name != name) {
        [_name release]; // release方法将_name所指旧对象的强引用数减1
        _name = [name retain]; // retain方法将name所指新对象的强引用数加1，返回新对象的地址。相当于让_name变为强引用
    }
}

- (NSInteger)age {
    return _age;
}

- (void)setAge:(NSInteger)age {
    _age = age;
}

- (void)dealloc {
    [_name release]; // 与setName:方法中的_name = [name retain];语句成对存在
    
    [super dealloc];
    NSLog(@"PBMemoryListMRCOne对象被释放了");
}

@end
#endif
