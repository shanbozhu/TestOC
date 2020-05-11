//
//  PBMemoryListMRC.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/11/29.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#ifdef OPENMRC
#import "PBMemoryListMRC.h"

@implementation PBMemoryListMRC

// 具有手动内存管理功能的getter和setter
- (PBMemoryListMRCOne *)testListMRCOne {
    return _testListMRCOne;
}

- (void)setTestListMRCOne:(PBMemoryListMRCOne *)testListMRCOne {
    if (_testListMRCOne != testListMRCOne) {
        [_testListMRCOne release];
        _testListMRCOne = [testListMRCOne retain];
    }
}

- (void)dealloc {
    [_testListMRCOne release];
    
    [super dealloc];
    NSLog(@"PBMemoryListMRC对象被释放了");
}

@end
#endif
